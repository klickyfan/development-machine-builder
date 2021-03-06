# This script sets up a Windows 10 laptop as recommended by Seal Pod (for Seal Pod
# project development). See https://github.com/klickyfan/development-machine-builder
# for more information.

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

        if ($($c.Value) -isnot [array]) {
            Write-BoxstarterMessage "Replacing {{ $($c.Name) }} with $($c.Value)..."
            $content = $content.replace("{{ $($c.Name) }}", $($c.Value))
        }
    }

    Set-Content -Path $path -value $content
}

function InstallChocolateyPackages {

    # make sure chocolatey is installed

    if (CheckCommand -cmdname 'choco') {
        Write-BoxstarterMessage "Choco is already installed, skip installation."
    }
    else {
        Write-BoxstarterMessage "Installing Chocolatey for Windows..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-BoxstarterMessage "Installation of Chocolatey complete."
    }

    foreach ($package in $Config.chocolatey_packages) {

        Write-BoxstarterMessage "Installing $($package.name)..."
        
        if ($($package.parameters) -And $($package.package_parameters)) {
            choco install $($package.name) --params "$($package.parameters)" --package-parameters  "$($package.package_parameters)" --cacheLocation="C:\temp" -y
        }  
        elseif ($($package.parameters)) {
            choco install $($package.name) --params "$($package.parameters)" --cacheLocation="C:\temp" -y
        }
        elseif ($($package.package_parameters)) {
            choco install $($package.name) --package-parameters "$($package.package_parameters)" --cacheLocation="C:\temp" -y
        }
        else {
            choco install $($package.name) --cacheLocation="C:\temp" -y
        }

        Write-BoxstarterMessage "Installation of $($package.name) complete!"

        refreshenv
    }

    Write-BoxstarterMessage "Packages installed!"
}

function InstallPowerShellPackages {

    foreach ($package in $Config.powershell_packages) {

        Write-BoxstarterMessage "Installing $($package)..."
        Write-BoxstarterMessage "Executing Install-Module -Name $($package) ..."
        Install-Module -Name $package -AllowClobber -Scope CurrentUser -Force
        Write-BoxstarterMessage "Installation of $($package) complete."

        refreshenv
    }
    
    Write-BoxstarterMessage "Packages installed!"
}

function InstallDotNetEF {

    dotnet tool install --global dotnet-ef --version $($Config.dotnet_ef_version)

    Write-BoxstarterMessage "dotnet ef installed!"
}

function SetEnvironmentVariables {

    [Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")

    Write-BoxstarterMessage "Environment variables set!"
}

function ConfigurePowerShell {

    $profilePath = "$Env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\PowerShell\Microsoft.PowerShell_profile.ps1") -Destination $profilePath

    Unblock-File -Path $profilePath

    Invoke-Expression $profilePath

    Write-BoxstarterMessage "Powershell configured!"
}

function ConfigureConEmu {

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\ConEmu\ConEmu.xml") -Destination "$Env:UserProfile\AppData\Roaming\ConEmu.xml"

    Write-BoxstarterMessage "Powershell configured!"
}

function ConfigureGit {

    SetContentFromTemplate "$Env:UserProfile\.gitconfig" ($BuildComponentsPath + "\configuration\git\.gitconfig")

    [System.IO.Directory]::CreateDirectory("$Env:UserProfile\Repos\Personal")
    [System.IO.Directory]::CreateDirectory("$Env:UserProfile\Repos\TheLevelUp")

    Write-BoxstarterMessage "Git configured!"
}

function ConfigureVSCode {

    [System.Environment]::SetEnvironmentVariable("PATH", "C:\Program Files\Microsoft VS Code\bin;" + $Env:Path, "Machine")

    foreach ($extension in $Config.visual_studio_code_extensions) {

        Write-BoxstarterMessage "Installing $($extension)..."
        code --install-extension $extension
        Write-BoxstarterMessage "Installation of $($extension) complete."

        refreshenv
    }

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\VisualStudioCode\settings.json") -Destination "$Env:UserProfile\AppData\Roaming\Code\User\settings.json"

    Write-BoxstarterMessage "Visual Studio Code configured!"
}

function InstallVSExtension {

    param($extension)
    
    $marketplaceProtocol = "https:"
    $marketplaceHostName = "marketplace.visualstudio.com"
    $visualStudioInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"

    $uri = "$($marketplaceProtocol)//$($marketplaceHostName)/items?itemName=$($extension)"

    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -SessionVariable session

    Write-BoxstarterMessage "Attempting to download $($extension) from $($uri)..."

    $anchor = $response.Links | Where-Object { $_.class -eq 'install-button-container' } | Select-Object -ExpandProperty href

    $href = "$($marketplaceProtocol)//$($marketplaceHostName)$($anchor)"

    $vsixLocation = "$($env:Temp)\$([guid]::NewGuid()).vsix"

    Invoke-WebRequest $href -OutFile $vsixLocation -WebSession $session

    Start-Process -Filepath "$($visualStudioInstallDir)\VSIXInstaller" -ArgumentList "/q /a $($vsixLocation)" -Wait

    rm $vsixLocation
}

function ConfigureVS {

    Copy-Item -Path ($BuildComponentsPath  + "\configuration\NuGet\NuGet.Config") -Destination "$Env:UserProfile\AppData\Roaming\NuGet\NuGet.Config"

    foreach ($extension in $Config.visual_studio_extensions) {
        Write-BoxstarterMessage "Installing $($extension)..."
        InstallVSExtension $extension
        Write-BoxstarterMessage "Installation of $($extension) complete!"
    }

    Write-BoxstarterMessage "Visual Studio configured!"
}

function ConfigureFileExplorer {

    # show hidden files
    cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f"

    # show file extensions
    cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"

    # open to "This PC" instead of "Quick access"
    cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

    Write-BoxstarterMessage "File Explorer configured!"
}

function RemoveCrap {

    foreach ($app in $Config.crap_apps) {
        Write-BoxstarterMessage "Removing $($app))..."
        Get-AppxPackage -Name $app | Remove-AppxPackage
        Write-BoxstarterMessage "Removal of $($app) complete."
    }

    Write-BoxstarterMessage "Crap removed!"
}

function AddThisPCDesktopIcon {

    $iconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $regValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    
    $item = Get-ItemProperty -Path $iconRegPath -Name $ergValname -ErrorAction SilentlyContinue
    if ($item) {
        Set-ItemProperty  -Path $iconRegPath -name $regValname -Value 0
    }
    else {
        New-ItemProperty -Path $iconRegPath -Name $regValname -Value 0 -PropertyType DWORD | Out-Null
    }
    
    Write-BoxstarterMessage "Icon added!"
}

$ErrorActionPreference = "Stop"

Import-Module (Join-Path $Boxstarter.BaseDir Boxstarter.Bootstrapper\Get-PendingReboot.ps1) -global -DisableNameChecking

$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

$BuildComponentsPath = [environment]::GetEnvironmentVariable("BUILD_COMPONENTS_PATH", "Machine")

$ErrorActionPreference = "Continue"

Write-BoxstarterMessage "----------------------------------------"
Write-BoxstarterMessage "            PART 1 - Prepare           "
Write-BoxstarterMessage "----------------------------------------"

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

Write-BoxstarterMessage "----------------------------------------"
Write-BoxstarterMessage "       PART 2 - Install Packages       "
Write-BoxstarterMessage "----------------------------------------"

Write-BoxstarterMessage "Installing Chocolatey packages..."
InstallChocolateyPackages

Write-BoxstarterMessage "Installing PowerShell packages..."
InstallPowerShellPackages

Write-BoxstarterMessage "Installing dotnet ef..."
InstallDotNetEF

Write-BoxstarterMessage "----------------------------------------"
Write-BoxstarterMessage "           PART 3 - Configure           "
Write-BoxstarterMessage "----------------------------------------"

Write-BoxstarterMessage "Setting environment variables..."
SetEnvironmentVariables

Write-BoxstarterMessage "Configuring PowerShell..."
ConfigurePowershell

Write-BoxstarterMessage "Configuring git..."
ConfigureGit

Write-BoxstarterMessage "Configuring Visual Studio Code..."
ConfigureVSCode

Write-BoxstarterMessage "Configuring Visual Studio..."
ConfigureVS

Write-BoxstarterMessage "Configuring File Explorer..."
ConfigureFileExplorer

Write-BoxstarterMessage "--------------------------------------"
Write-BoxstarterMessage "            PART 4 - Misc.            "
Write-BoxstarterMessage "--------------------------------------"

Write-BoxstarterMessage "Removing crap..."
RemoveCrap

Write-BoxstarterMessage "Adding 'This PC' Desktop icon..."
AddThisPCDesktopIcon
