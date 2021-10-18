# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module posh-git

# See https://docs.google.com/document/d/1RrRuwgPh2OVP05fVQT5iUlCkTfJzTpocs7eJckSmGaY/edit#heading=h.4wv615dv4f1l
Import-Module z

# Create a symbolic link between the current working directory and the target directory
function Make-Junction([string]$target) {
  New-Item -ItemType Junction -Path $target -Value (Get-Item -Path ".\").FullName
}
