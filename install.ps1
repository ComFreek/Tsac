<#
    This script installs or updates Tsac.

    - Creates Tsac directory:
        Program Files [(x86)]\Microsoft SDKs\TypeScript\0.8.0.0

    - Copies compile1.ps1 file: a wrapper script for calling the actual TypeScript compiler

    - Copies winjs.d.ts and winrt.d.ts from the public TypeScript repository (after downloading that via git checkout)


    NOTE that you have to run this script as an Administrator, it will display an error message otherwise!

    @license MIT, see LICENSE file.
#>

<#
  Thanks to Boe Prox!
  http://blogs.technet.com/b/heyscriptingguy/archive/2011/05/11/check-for-admin-credentials-in-a-powershell-script.aspx
#>
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "The script tries to re-run itself using Administrator privileges.";
    try {
        Start-Process powershell -ArgumentList ($MyInvocation.MyCommand.Path) -Verb runAs;
    }
    catch [InvalidOperationException] {
        Write-Warning "You canceled the privilege request. This script WON'T WORK, please re-run it!";
        Read-Host;
        Exit;
    }
    
    # Posted a question on StackOverflow concerning this issue:
    # http://stackoverflow.com/questions/13323157/delay-in-closing-powershell-window-when-started-via-start-process-with-admin-rig
    Write-Warning "The window appearing now won't close directly after clicking [X]. This will take 3-5 seconds. That's normal behaviour.";
    Exit;
}

Write-Host "This script will install/update Tsac.";
Write-Host "Project site: http://github.com/ComFreek/Tsac";
Write-Host "";

<#
    Returns the temporary
#>
function getTmpDir() {
    return $env:TMP + '\TypeScript\';
}

$tmpDir = getTmpDir;

Read-Host "Ready for downloading the whole TypeScript Git archive? This can take several minutes! [Press enter]";

# Don't show git checkout's progress (they're stated as errors by PowerShell)!
$tmpOutFile = [System.IO.Path]::GetTempFileName();
$cmd = 'git clone --quiet https://git01.codeplex.com/typescript "' + $tmpDir + '" > ' + $tmpOutFile;
Invoke-Expression $cmd;
Remove-Item $tmpOutFile;

$tsacDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path);
Copy-Item ($tmpDir + "\bin\winrt.d.ts") $tsacDir;
Copy-Item ($tmpDir + "\bin\winjs.d.ts") $tsacDir;

Remove-Item -Recurse -Force $tmpDir;

Write-Host "Files have been copied. Thanks for using this script!";

