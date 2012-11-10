<#
    This script implements a function which converts an absolute path to a relative one.

    I published this script at StackOverflow, too: http://stackoverflow.com/a/13239621/603003

    @license MIT, see LICENSE file.
#>


<#
    Gets a path relative to another from an absolute path.
    
    $from The absolute path
    $to The relative path
    $joinSlash Optional, defaults to '/'. Specifies the path separator to use in the returned value.
    
    Returns the relative path.   
    
    Thanks to Gordon for his algorithm:
        http://stackoverflow.com/questions/2637945/getting-relative-path-from-absolute-path-in-php/2638272#2638272
#>
function getRelativePath([string]$from, [string]$to, [string]$joinSlash='/') {
    $from = $from -replace "(\\)", "/";
    $to = $to -replace "(\\)", "/";


    $fromArr = New-Object System.Collections.ArrayList;
    $fromArr.AddRange($from.Split("/"));

    $relPath = New-Object System.Collections.ArrayList;
    $relPath.AddRange($to.Split("/"));


    $toArr = New-Object System.Collections.ArrayList;
    $toArr.AddRange($to.Split("/"));

    for ($i=0; $i -lt $fromArr.Count; $i++) {
        $dir = $fromArr[$i];

        # find first non-matching dir
        if ($dir.Equals($toArr[$i])) {
            # ignore this directory
            $relPath.RemoveAt(0);
        }
        else {
            # get number of remaining dirs to $from
            $remaining = $fromArr.Count - $i;
            if ($remaining -gt 1) {
                # add traversals up to first matching dir
                $padLength = ($relPath.Count + $remaining - 1);

                # emulate array_pad() from PHP
                for (; $relPath.Count -ne ($padLength);) {
                    $relPath.Insert(0, "..");
                }
                break;
            }
            else {
                $relPath[0] = "./" + $relPath[0];
            }
        }
    }
    return $relPath -Join $joinSlash;
}