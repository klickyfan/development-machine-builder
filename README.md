This repo contains the components needed to set up a new Windows 10 laptop as 
(recommended by Seal Pod)[https://levelup.atlassian.net/wiki/spaces/POS/pages/299532297/Chapter+6+Tools]
(for Seal Pod project development). Most important of these  is Build.ps1, a 
PowerShell script that performs all the steps needed, though it should not be
run directly, but rather by running KickOffBuild.ps1, which uses Boxstarter--an 
open source tool described below--to allow reboots
to occur as needed while the work is progressing.

**Boxstarter

Boxstarter is an open source tool that allows you to run a PowerShell script
which may require a reboot

**Instructions for Use

1. Determine if the new laptop is in need of Windows Updates, and reboot if so.

2. Download this repo onto your desktop via (this url)[https://codeload.github.com/klickyfan/development-machine-builder/zip/master]

3. Copy settings.template.json to settings.json and fill in the blanks.

4. Modify configuration files as desired.

5. Set the new laptop's PowerShell Execution Policy from Restricted to 
   RemoteSigned (as an administrator).

6. Run KickOffBuild.ps1.

7. Stick around to do occasional babysitting. More on this below.

8. Run InstallVSExtensions.ps1.

**Babysitting Required

Ideally the build process could be run without having to be attended. But...

**Logs That May Be Useful

C:\ProgramData\chocolatey\logs\chocolatey.log)
~\AppData\Local\Boxstarter\boxstarter.log 

**Additional Work To Do

There are some things the Build.ps1 script does not do that you may want to do
yourself:

* update Microsoft Edge
* sign in to your preferred browser(s)
* sign in to OneDrive
* sign in to Getihub Desktop
