# development-machine-builder/zip/master

This repo contains the components needed to set up a new Windows 10 laptop as (recommended by Seal
Pod)[https://levelup.atlassian.net/wiki/spaces/POS/pages/299532297/Chapter+6+Tools] (for Seal Pod
project development). Most important of these  is Build.ps1, a  PowerShell script that performs all
the steps needed, though it should not be run directly, but rather by running KickOffBuild.ps1, 
which uses Boxstarter--an open source tool described below--to allow reboots to occur as needed
while the work is progressing.

**Boxstarter**

(Boxstarter)[www.boxstarter.org] is an open source tool detects whether a reboot is required during
the execution of a PowerShell Script, forces the reboot, and then resumes the script after the
reboot.

**Instructions for Use**

1. Determine if the new laptop is in need of Windows Updates, and reboot if so.

2. Download this repo onto your desktop via
   (this url)[https://codeload.github.com/klickyfan/development-machine-builder/zip/master]

3. Copy settings.template.json to settings.json and fill in the blanks.

4. Modify other configuration files as desired.

5. Set the new laptop's PowerShell Execution Policy from Restricted to 
   RemoteSigned (as an administrator).

6. Run KickOffBuild.ps1.

7. Stick around to do occasional babysitting. More on this below.

**Babysitting Required**

Ideally the build process could be run without having to be attended. But...

**Logs That May Be Useful**

C:\ProgramData\chocolatey\logs\chocolatey.log
~\AppData\Local\Boxstarter\boxstarter.log 

**Additional Work To Do**

There are some things the Build.ps1 script does not do that you may want to do
yourself:

* update Microsoft Edge
* sign in to your preferred browser(s)
* sign in to OneDrive
* sign in to Getihub Desktop

**Additional Notes**

Information about Chocolatey packages can be found
(here)[https://community.chocolatey.org/packages].

Information about PowerShell packages can be found
(here)[https://www.powershellgallery.com/packages].

Information about Visual Studio and Visual Studio Code extensions can be found
(here)[https://marketplace.visualstudio.com].

To list all appx packages (applications you may want the script to remove):
    Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
