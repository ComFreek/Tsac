<#
    This scripts implements functions for adding TypeScript ability to a VS 2012 project.

    @todo
        Better organize the script's data structure. $projData is an evil global variable!
        If you do edit this script, be sure to check compatibility with gui.ps1!

    @license MIT, see LICENSE file.
#>

. ".\relPath.ps1";

$projData = @{};

function loadProject([string] $fileName) {
    [xml] $projData.xml = Get-Content $fileName;
    $projData.dir = [IO.Path]::GetDirectoryName($fileName);
    
    $projData.activeJsFiles = @();

    $projData.jsFiles = @();
    $i = 0;
    Select-Xml "//*[local-name()='ItemGroup']/*[local-name()='Content' and '.js' = substring(@Include, string-length(@Include) - 2)]" $projData.xml | % {
        if (!$_.Node.DependentUpon) {
            $projData.jsFiles += $_.Node;
            $projData.activeJsFiles += $i;
            $i++;
        }
    } | Out-Null;
    return $projData;
}

function saveProject([string] $fileName) {
    $projData.xml = [xml] $projData.xml.OuterXml.Replace(" xmlns=`"`"", "");
    $projData.xml.Save($fileName);
}

function convProject($firstUse=$True) {
    $project = $projData.xml.Project;
    $root = $projData.xml;

    if (!$project.Target) {
        $beforeBuild = $root.CreateElement("Target");
        $beforeBuild.SetAttribute("Name", "BeforeBuild");
        $project.AppendChild($beforeBuild) | Out-Null;
    }

    if ($firstUse) {
        $tsExec = $root.CreateElement("Exec");
        $propGroup = $root.CreateElement("PropertyGroup");
        $propGroup.InnerXml = @"
  <TypeScriptSourceMap> --sourcemap</TypeScriptSourceMap>
"@;
        $project.AppendChild($propGroup);
        $tsExecCmdAttr = $root.CreateAttribute("Command");
        #tsc$(TypeScriptSourceMap) @(TypeScriptCompile ->'&quot;%(fullpath)&quot;', ' ')
        #$tsExecCmdAttr.InnerXml = "&quot;`$(PROGRAMFILES)\Microsoft SDKs\TypeScript\0.8.0.0\tsc&quot; -target ES5 `"`$(PROGRAMFILES)\Microsoft SDKs\TypeScript\0.8.0.0\winrt.d.ts`" `"`$(PROGRAMFILES)\Microsoft SDKs\TypeScript\0.8.0.0\winjs.d.ts`" @(TypeScriptCompile ->'&quot;%(fullpath)&quot;', ' ')";
        $tsExecCmdAttr.InnerXml = "tsc`$(TypeScriptSourceMap) -target ES5 @(TypeScriptCompile -&gt;'&quot;%(fullpath)&quot;', ' ')";
        $tsExec.SetAttributeNode($tsExecCmdAttr) | Out-Null;
        
        $tsExec.SetAttribute("IgnoreExitCode", "true");

        $outputElem = $root.CreateElement("Output");
        $outputElem.SetAttribute("PropertyName", "BuildSLNWarningCount");
        $outputElem.SetAttribute("TaskParameter", "ExitCode");

        $tsExec.AppendChild($outputELem);
            
        Select-Xml "//Target[@Name='BeforeBuild']" $root | % {
            $_.Node.AppendChild($tsExec);
        } | Out-Null;
    }

    $items = $project.ItemGroup.childNodes;
    $projData.activeJsFiles | % {
        $node = $projData.jsFiles[$_];

        $src = $node.GetAttribute("Include");
        # Normalize $src
        $src = [IO.Path]::GetFullPath( (Join-Path -Path $projData.dir -ChildPath $src) );

        # Add a <DependentUpon> child element
        $depElem = $root.CreateElement("DependentUpon");
        $depElem.innerText = [System.IO.Path]::GetFileNameWithoutExtension($src) + ".ts";

        $node.AppendChild($depElem) | Out-Null;

        $jsFile = [System.IO.Path]::GetFullPath($src);
        $tsFile = [System.IO.Path]::GetDirectoryName($src) + "\" + [IO.Path]::GetFileNameWithoutExtension($src) + ".ts";

        Copy-Item $jsFile $tsFile;

        # Also include <None> element for each inserted *.ts dependency
        $noneElem = $root.CreateElement("None");
        $noneInc = getRelativePath -From $projData.dir -To $tsFile -JoinSlash "\";
        $noneElem.SetAttribute("Include", $noneInc);
        $node.ParentNode.AppendChild($noneElem) | Out-Null;
    }
    
    if ($firstUse) {
        $tscItemGroup1 = $root.CreateElement("ItemGroup");
        $tscItemGroup1.InnerXml = '<AvailableItemName Include="TypeScriptCompile" />';
        $project.AppendChild($tscItemGroup1) | Out-Null;
    
        $tscItemGroup2 = $root.CreateElement("ItemGroup");
        $tscItemGroup2.InnerXml = '<TypeScriptCompile Include="$(ProjectDir)\**\*.ts" />';
        $project.AppendChild($tscItemGroup2) | Out-Null;
    }
}