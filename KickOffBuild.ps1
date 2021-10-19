if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy RemoteSigned -File `"$PSCommandPath`"" -Verb RunAs;
    exit
}

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force

Write-Host "Storing path to settings file..."
$dir = Split-Path $MyInvocation.MyCommand.Path
[Environment]::SetEnvironmentVariable("BUILD_COMPONENTS_PATH", "$dir", "Machine")
Write-Host "Path to settings file stored."

Write-Host "Installing Boxstarter"
. { Invoke-WebRequest -useb http://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; get-boxstarter -Force
Write-Host "Boxstarter installed."

Write-Host "Kicking off build!"
$credential = Get-Credential
Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/klickyfan/development-machine-builder/main/Build.ps1 -Credential $credential

# This line will never be reached if a reboot is required during the build, but it can be useful
# (in preventing the PowerShell window from going away) if the build fails.
Read-Host
