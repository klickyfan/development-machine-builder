if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy RemoteSigned -File `"$PSCommandPath`"" -Verb RunAs; 
    exit 
}


[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force

Write-Host "Storing config path"
$dir = Split-Path $MyInvocation.MyCommand.Path
[Environment]::SetEnvironmentVariable("BoxstarterBuildSettingsFile", "$dir\settings.json", "Machine") 
Write-Host "Config path stored"

Write-Host "Installing boxstarter"
. { Invoke-WebRequest -useb http://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; get-boxstarter -Force
Write-Host "Boxstarter successfully installed"

Write-Host "Running InstallBox"
Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/klickyfan/507cf20a73640174869efc00589ac2f1/raw/BoxStarterBuild.ps1
Write-Host "InstallBox script finished"

Read-Host
