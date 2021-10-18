# This script sets up a Windows 10 laptop as recommended by Seal Pod (for Seal Pod 
# project development). See <link to repo tbd> for more information.

function SetTimeZone {   

    Set-TimeZone -Name "Eastern Standard Time"
    
    Write-BoxstarterMessage "Time zone set!"
}

function CheckCommand($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function SetContentFromTemplate {
          
    param($path, $templatePath)
    
    $content = Get-Content $templatePath
    
    foreach ($c in $Config.GetEnumerator()) {
        
        $content = $content.replace("{{ $($c.Name) }}", $($c.Value))
    }
    
    Set-Content -Path $path -value $content
}

function InstallPackages {
    
    # make sure chocolatey is installed
    
    if (CheckCommand -cmdname 'choco') {
        Write-BoxstarterMessage "Choco is already installed, skip installation."
    }
    else {
        Write-BoxstarterMessage "Installing Chocolatey for Windows..." 
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    
    choco install choco-cleaner --cacheLocation="C:\temp"; refreshenv
    
    #install chocolatey packages that take no parameters
    
    $apps = @(
        "7zip.install",
        "googlechrome",
        "notepadplusplus.install",
        "nuget.commandline",
        "git",      
        "poshgit",
        "github-desktop",
        "sourcetree",
        "gitversion.portable",
        "wixtoolset",
        "pgadmin4",
        "conemu",
        "autohotkey",
        "chocolateygui",
        "freshbing")

    foreach ($app in $apps) {
        choco install $app --cacheLocation="C:\temp" -y
    }
    
    # install additional chocolatey packages
    
    choco install vscode --params '/NoDesktopIcon' --cacheLocation="C:\temp" -y
    
    choco install visualstudio2019professional -y --package-parameters '--allWorkloads --includeRecommended --passive' --cacheLocation="C:\temp" -y    
    choco install visualstudio-github --cacheLocation="C:\temp" -y

    choco install postgresql13 --params "/Password:$($Config.postgres_password)" --cacheLocation="C:\temp" -y
    
    # refresh the current PowerShell session with all environment settings possibly performed by package installs
    
    refreshenv

    Write-BoxstarterMessage "Packages installed!"
}

function InstallDotNetEF {
    
    dotnet tool install --global dotnet-ef
    dotnet tool update --global dotnet-ef
    
    Write-BoxstarterMessage "dotnet ef installed!"
}

function SetEnvironmentVariables {
    
    [Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")

    Write-BoxstarterMessage "Environment variables set!"
}

function ConfigurePowerShell {
    
    Copy-Item -Path ($BuildComponentsPath  + "\configuration\PowerShell\Microsoft.PowerShell_profile.ps1") -Destination "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    
    Invoke-Expression "$env:userprofile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    
    Write-BoxstarterMessage "Powershell configured!"
}

function ConfigureConEmu {
    
    Copy-Item -Path ($BuildComponentsPath  + "\configuration\ConEmu\ConEmu.xml") -Destination "$env:userprofile\AppData\Roaming\ConEmu.xml"
    
    Write-BoxstarterMessage "Powershell configured!"
}

function ConfigureGit {
    
    SetContentFromTemplate "$env:userprofile\.gitconfig" ($BuildComponentsPath + "\configuration\git\.gitconfig")
    
    [System.IO.Directory]::CreateDirectory("$env:userprofile\Repos\Personal")
    [System.IO.Directory]::CreateDirectory("$env:userprofile\Repos\TheLevelUp")
    
    Write-BoxstarterMessage "Git configured!"
}

function ConfigureVSCode {
    
    [System.Environment]::SetEnvironmentVariable("PATH", "C:\Program Files\Microsoft VS Code\bin;" + $env:Path, "Machine")
      
    code --install-extension streetsidesoftware.code-spell-checker
    code --install-extension yzhang.markdown-all-in-one
    code --install-extension bierner.markdown-preview-github-styles
    code --install-extension ms-vscode.PowerShell
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension rvest.vs-code-prettier-eslint
    code --install-extension msjsdiag.vscode-react-native
    code --install-extension rebornix.ruby

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\VisualStudioCode\settings.json") -Destination "$env:userprofile\AppData\Roaming\Code\User\settings.json"
  
    Write-BoxstarterMessage "Visual Studio Code configured!"
}

function ConfigureVS {

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\NuGet\NuGet.Config") -Destination "$env:userprofile\AppData\Roaming\NuGet\NuGet.Config"

    Write-BoxstarterMessage "Visual Studio configured!"
}

function ConfigureFileExplorer {

    # show file extensions
    cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"

    # open to "This PC" instead of "Quick access"
    cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

    Write-BoxstarterMessage "File Explorer configured!"
}

function RemoveCrap {

    # To list all appx packages:
    # Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
    
    $apps = @(
        "Microsoft.Messaging",
        "Microsoft.People",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.GetHelp")

    foreach ($app in $apps) {
        Get-AppxPackage -Name $app | Remove-AppxPackage
    }
    
    Write-BoxstarterMessage "Crap removed!"
}

function AddThisPCDesktopIcon {

    $thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 
    $item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue 
    if ($item) { 
        Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0  
    } 
    else { 
        New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null  
    } 
}

function GetWindowsUpdates {
    
    Install-Module -Name PSWindowsUpdate -Force
    Write-BoxstarterMessage "Installing updates... (Computer will reboot in minutes...)"
    Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot
}

$ErrorActionPreference = "Stop"

Import-Module (Join-Path $Boxstarter.BaseDir Boxstarter.Bootstrapper\Get-PendingReboot.ps1) -global -DisableNameChecking

$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

$BuildComponentsPath = [environment]::GetEnvironmentVariable("BUILD_COMPONENTS_PATH", "Machine")

$ErrorActionPreference = "Continue"

Write-BoxstarterMessage "---------------------------------"
Write-BoxstarterMessage "        PART 1 - Prepare         "
Write-BoxstarterMessage "---------------------------------"

Write-BoxstarterMessage "Setting execution policy..."
Set-ExecutionPolicy Bypass -Scope Process -Force

Write-BoxstarterMessage "Reading settings.json..."

$Config = @{}
(Get-Content -Path ($BuildComponentsPath  + "\settings.json") -Raw | ConvertFrom-Json).psobject.properties | Foreach { $Config[$_.Name] = $_.Value }

Write-BoxstarterMessage "Setting time zone..."
SetTimeZone

Write-BoxstarterMessage "Disabling Sleep on AC Power..."
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

Write-BoxstarterMessage "---------------------------------"
Write-BoxstarterMessage "        PART 2 - Install         "
Write-BoxstarterMessage "---------------------------------"

Write-BoxstarterMessage "Installing packages..."
#InstallPackages

Write-BoxstarterMessage "Installing dotnet ef..."
#InstallDotNetEF

Write-BoxstarterMessage "---------------------------------"
Write-BoxstarterMessage "        PART 3 - Configure       "
Write-BoxstarterMessage "---------------------------------"

Write-BoxstarterMessage "Setting environment variables..."
SetEnvironmentVariables

Write-BoxstarterMessage "Configuring PowerShell..."
ConfigurePowershell
    
Write-BoxstarterMessage "Configuring git..."
ConfigureGit -Parameters $arguments

Write-BoxstarterMessage "Configuring Visual Studio Code..."
ConfigureVSCode

Write-BoxstarterMessage "Configuring Visual Studio..."
ConfigureVS

Write-BoxstarterMessage "Configuring File Explorer..."
ConfigureFileExplorer


Write-BoxstarterMessage "---------------------------------"
Write-BoxstarterMessage "        PART 4 - Misc.           "
Write-BoxstarterMessage "---------------------------------"

Write-BoxstarterMessage "Removing crap..."
RemoveCrap

Write-BoxstarterMessage "Adding 'This PC' Desktop Icon..."
AddThisPCDesktopIcon
