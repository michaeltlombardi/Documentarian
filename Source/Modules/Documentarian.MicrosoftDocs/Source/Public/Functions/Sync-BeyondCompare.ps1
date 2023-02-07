# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Sync-BeyondCompare {

    param([string]$path)
    $gitStatus = Get-GitStatus
    if ($gitStatus) {
        $reponame = $GitStatus.RepoName
    } else {
        'Not a git repo.'
        return
    }
    $repoPath  = $global:git_repos[$reponame].path
    $ops       = Get-Content $repoPath\.openpublishing.publish.config.json | ConvertFrom-Json -Depth 10 -AsHashtable
    $srcPath   = $ops.docsets_to_publish.build_source_folder
    if ($srcPath -eq '.') {$srcPath = ''}
    $basePath  = Join-Path $repoPath $srcPath '\'
    $mapPath   = Join-Path $basePath $ops.docsets_to_publish.monikerPath
    $monikers  = Get-Content $mapPath | ConvertFrom-Json -Depth 10 -AsHashtable
    $startPath = (Get-Item $path).fullname

    $vlist = $monikers.keys | ForEach-Object { $monikers[$_].packageRoot }
    if ($startpath) {
        $relPath = $startPath -replace [regex]::Escape($basepath)
        $version = ($relPath -split '\\')[0]
        foreach ($v in $vlist) {
            if ($v -ne $version) {
                $target = $startPath -replace [regex]::Escape($version), $v
                if (Test-Path $target) {
                    Start-Process -Wait "${env:ProgramFiles}\Beyond Compare 4\BComp.exe" -ArgumentList $startpath, $target
                }
            }
        }
    } else {
        "Invalid path: $path"
    }

}