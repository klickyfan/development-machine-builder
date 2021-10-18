# development-machine-builder/zip/master

This repo contains the components needed to set up a new Windows 10 laptop as [recommended by Seal
Pod](https://levelup.atlassian.net/wiki/spaces/POS/pages/299532297/Chapter+6+Tools) (for Seal Pod
project development). Most important of these  is Build.ps1, a  PowerShell script that performs all
the steps needed, though it should not be run directly, but rather by running KickOffBuild.ps1, 
which uses Boxstarter--an open source tool described below--to allow reboots to occur as needed
while the work is progressing.

**Boxstarter**

(Boxstarter)[www.boxstarter.org] is an open source tool detects whether a reboot is required during
the execution of a PowerShell Script, forces the reboot, and then resumes the script after the
reboot.

**Usage Instructions**

1. Determine if the new laptop is in need of Windows Updates, and reboot if so.

2. Download this repo onto your desktop via
   [this url](https://codeload.github.com/klickyfan/development-machine-builder/zip/ma). (Getting
   it this way does not require git.)

3. Copy settings.template.json to settings.json and fill in the blanks.

4. Modify other configuration files as desired.

5. Set the new laptop PowerShell Execution Policy from Restricted to 
   RemoteSigned (as an administrator).

6. Run KickOffBuild.ps1.

7. Stick around to do occasional babysitting. More on this below.

**Babysitting Required**

Ideally the build process could be run without having to be attended. But... thanks to our IT 
department's very restrictive policies...

**Logs That May Be Useful**

C:\ProgramData\chocolatey\logs\chocolatey.log
~\AppData\Local\Boxstarter\boxstarter.log 

**Additional Work To Do**

There are some things the Build.ps1 script does not do that you may want to do yourself:

* update Microsoft Edge
* sign in to your preferred browser(s)
* sign in to OneDrive and/or Google Drive
* sign in to Visual Studio
* sign in to Github Desktop
* add an [Autohotkey](https://www.autohotkey.com/) script to %appdata%\Microsoft\Windows\Start Menu\Programs\Startup
* get the [Postman Agent](https://blog.postman.com/introducing-the-postman-agent-send-api-requests-from-your-browser-without-limits/)

**Additional Notes and Resources**

Information about Chocolatey packages can be found
[here](https://community.chocolatey.org/packages).

Information about PowerShell packages can be found
[here](https://www.powershellgallery.com/packages).

Information about Visual Studio and Visual Studio Code extensions can be found
[here](https://marketplace.visualstudio.com).

To list all appx packages (applications you may want the script to remove):
```
Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
```

[Forest's ConEmu Cheat Sheet](https://docs.google.com/document/d/13rbTm06QsbGDe4UHbsJlmxMoRh_yKvEJ9vByQxK-VEA)
[Kim's Introduction to z](https://docs.google.com/document/d/1RrRuwgPh2OVP05fVQT5iUlCkTfJzTpocs7eJckSmGaY)
[Forest's Autohotkey scripts](https://github.com/forestb/autohotkey-scripts)
[Sean's Autohotkey script](https://gist.github.com/sxmanton/ec91ad6a6fd31a57e7eb152ad837dcb9)
[Sean's PowerShell shortcuts](https://gist.github.com/sxmanton/f980cbc5fbd660e89c997c069db6fa4f)

***Articles About Automating Machine Builds***
https://azuresamurai.blog/2020-11-05-Automating-your-dev-env/
http://www.hurryupandwait.io/blog/easily-script-machine-reinstalls-with-boxstarter
https://joshuachini.com/2017/10/27/automated-setup-of-a-windows-environment-using-boxstarter-and-powershell/
https://ttu.github.io/use-chocolatey-to-install-apps-windows-dev-machine/
https://octopus.com/blog/automate-developer-machine-setup-with-chocolatey

***Build Scripts Created by Others***
https://github.com/nas963/ChocolateyBoxstarter
https://github.com/crfroehlich/chocolatey-vs
https://github.com/Anduin2017/configuration-script-win
https://github.com/Tandolf/dotfiles
https://github.com/tpodolak/InstallBox/
https://github.com/EdiWang/EnvSetup
https://gist.github.com/gbuktenica/4621203134b41ef09746e6faa4ecbd3f
https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
https://gist.github.com/flcdrg/87802af4c92527eb8a30

