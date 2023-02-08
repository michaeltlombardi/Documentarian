# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
#requires -Module InvokeBuild

[cmdletbinding()]
param()

task SyncVale {
  $SourceStyleFolder = Get-Item -Path $PSScriptRoot/Source/Styles
  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $SubFolder = Join-Path -Path $_.FullName -ChildPath $_.BaseName
    if (Test-Path -Path $SubFolder) {
      Remove-Item -Path $SubFolder -Recurse -Force
    }
    $null = New-Item -Path $SubFolder -ItemType Directory

    $null = Get-ChildItem $_ -File | Copy-Item -Destination $SubFolder -Force
  }

  vale sync

  $SyncedStyleFolder = Get-Item -Path $PSScriptRoot/.vscode/styles
  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $SubFolder = Join-Path -Path $_.FullName -ChildPath $_.BaseName
    Remove-Item -Path $SubFolder -Recurse -Force
    Copy-Item -Path $_ -Destination $SyncedStyleFolder -Force -Container -Recurse
  }
}

task PackageVale {
  $SourceStyleFolder = Get-Item -Path $PSScriptRoot/Source/Styles
  $PackagedStyleFolder = Join-Path $PSScriptRoot -ChildPath 'PackagedStyles'

  if (Test-Path -Path $PackagedStyleFolder) {
    Remove-Item -Path $PackagedStyleFolder -Recurse -Force
  }
  $null = New-Item -Path $PackagedStyleFolder -ItemType Directory

  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $CompressionParameters = @{
      Path            = $_.FullName
      DestinationPath = Join-Path -Path $PackagedStyleFolder -ChildPath "$($_.BaseName).zip"
      Force           = $true
    }
    Compress-Archive @CompressionParameters
  }
}
