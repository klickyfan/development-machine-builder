# This script installs VS extensions (downloaded from the Visual Studio
# Marketplace.
#
# To run it:
#
#   1. Close Visual Studio (if it is open).
#
#   2. Sign in at https://marketplace.visualstudio.com (to avoid being blocked
#      due to Anonymous usage rate limits).
#
#   3. Run PowerShell as administrator.
#
#   4. cd to the directory containing the script and execute it.

function Install-Extension {

    Param($extensionName)

    $uri = "$($MarketplaceProtocol)//$($MarketplaceHostName)/items?itemName=$($extensionName)"
    
    Write-Host "Grabbing extension at $($uri)..."
    
    $response = Invoke-WebRequest -Uri $uri -UseBasicParsing -SessionVariable session
     
    Write-Host "Attempting to download $($extensionName)..."
    
    $anchor = $response.Links | Where-Object { $_.class -eq 'install-button-container' } |
    Select-Object -ExpandProperty href

    if (-Not $anchor) {
      Write-Error "Could not find the download anchor tag."
      Exit 1
    }
    
    Write-Host "anchor = $($anchor)"
    
    $href = "$($MarketplaceProtocol)//$($MarketplaceHostName)$($anchor)"
    Write-Host "href = $($href)"
       
    $vsixLocation = "$($env:Temp)\$([guid]::NewGuid()).vsix"
    Write-Host "visxLocation = $($vsixLocation)"
    
    Invoke-WebRequest $href -OutFile $vsixLocation -WebSession $session
     
    if (-Not (Test-Path $vsixLocation)) {
      Write-Error "Could not find the location of the downloaded VSIX file."
      Exit 1
    }
    
    Write-Host "Installing $($extensionName)..."
    Start-Process -Filepath "$($VisualStudioInstallDir)\VSIXInstaller" -ArgumentList "/q /a $($vsixLocation)" -Wait
     
    Write-Host "Cleaning up..."
    rm $vsixLocation
     
    Write-Host "Installation of $($extensionName) complete!"
}

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
    exit 
}

$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path
. "$ScriptRoot\WriteLog.ps1"

$MarketplaceProtocol = "https:"
$MarketplaceHostName = "marketplace.visualstudio.com"

$VisualStudioInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"
 
if (-Not $VisualStudioInstallDir) {
  Write-Error "Visual Studio is not installed."
  Exit 1
}

# Extension names come from the Visual Studio Marketplace URL itemName parameter.
# Example: https://marketplace.visualstudio.com/items?itemName=GitHub.GitHubExtensionforVisualStudio

Write-Log "Step 3: Installing \"Clean Bin and Obj\"..."
Install-Extension dobrynin.cleanbinandobj
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"GitHub Extension for Visual Studio\"..."
Install-Extension GitHub.GitHubExtensionforVisualStudio
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"Roslynator 2019\"..."
Install-Extension josefpihrt.Roslynator2019
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"Add New File\"..."
Install-Extension MadsKristensen.AddNewFile
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"Fast Find\"..."
Install-Extension PureDevSoftware.FastFind
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"Editor Guidelines\"..."
Install-Extension PaulHarrington.EditorGuidelines
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"CodeMaid\"..."
Install-Extension SteveCadwallader.CodeMaid
Write-Log "Step 3: Installation complete."

Write-Log "Step 3: Installing \"Visual Assist\"..."
Install-Extension WholeTomatoSoftware.VisualAssist
Write-Log "Step 3: Installation complete."

#Install-Extension JetBrains.ReSharper
#Install-Extension PostSharpTechnologies.PostSharp

Read-Host -Prompt "Press [enter]:"

