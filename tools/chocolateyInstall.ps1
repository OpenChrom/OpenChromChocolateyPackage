$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$ZipArgs = @{
   PackageName   = $env:ChocolateyPackageName
   url           = 'https://products.lablicate.com/openchrom/1.4.x/openchrom-lablicate_win32.x86_64_1.4.x.zip'
   checksum      = '{SHA256CHECKSUM}'
   ChecksumType  = 'sha256'
   UnzipLocation = Join-Path (Split-Path $toolsDir) "$env:ChocolateyPackageName$env:ChocolateyPackageVersion"
}

Install-ChocolateyZipPackage @ZipArgs

$exes = Get-ChildItem $ZipArgs.UnzipLocation | 
            Where-Object {$_.psiscontainer} | 
            ForEach-Object {Get-ChildItem $_.fullname -filter "*.exe" -Recurse}

foreach ($exe in $exes) {
   New-Item "$($exe.fullname).ignore" -Type file -Force | Out-Null
}

$GUI = (Get-ChildItem $ZipArgs.UnzipLocation -filter "$env:ChocolateyPackageName.exe").fullname
New-Item "$GUI.gui" -Type file -Force | Out-Null

$Linkname = "OpenChrom v$env:ChocolateyPackageVersion.lnk"
$StartPrograms = Join-Path $env:ProgramData '\Microsoft\Windows\Start Menu\Programs'

$ShortcutArgs = @{
   ShortcutFilePath = Join-Path $StartPrograms $Linkname
   TargetPath = $GUI
   IconLocation = Join-Path $toolsDir 'openchrom.ico'
}

Install-ChocolateyShortcut @ShortcutArgs
