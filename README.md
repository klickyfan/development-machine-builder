# development-machine-builder

This repo contains the components needed to set up a new Windows 10 laptop as [recommended by Seal
Pod](https://levelup.atlassian.net/wiki/spaces/POS/pages/299532297/Chapter+6+Tools) (for Seal Pod
project development). Most important of these is Build.ps1, a  PowerShell script that performs all
the steps needed, though it should not be run directly, but rather by running KickOffBuild.ps1, 
which uses Boxstarter--an open source tool described below--to allow reboots to occur as needed
while the work is progressing. Hopefully it will prove useful both to new hires and to and those
whose Dell's have failed us.

[Boxstarter](www.boxstarter.org) is an open source tool detects whether a reboot is required during
the execution of a PowerShell Script, forces the reboot, and then relogs you in and resumes the 
script after the reboot.

**Usage Instructions**

1. Determine if the new laptop is in need of Windows Updates, and reboot if so.

2. Download this repo onto your desktop via
   [this url](https://codeload.github.com/klickyfan/development-machine-builder/zip/main) and
   extract it. (Getting it this way does not require git.)

3. Copy settings.template.json to settings.json and fill in the blanks.

4. Modify other configuration files as desired, either manually or by copying the ones on yout
   old laptop from these locations:
   
   ConEmu.xml: %appdata%<br>
   .gitconfig: ~\.gitconfig<br>
   .Nuget.Config %appdata%\NuGet<br>
   Microsoft.PowerShell_profile.ps1: ~\Documents\WindowsPowerShell<br>
   Visual Studio Code settings.json: %appdata\Code\User<br>
 
5. Set the new laptopPowerShell Execution Policy from Restricted to Unrestricted (as an
   administrator). (You can set it back after.)

6. Run KickOffBuild.ps1.

7. Stick around to do occasional babysitting. More on this below.

**Babysitting Not Required... Much**

For the most part the build will run independently, though you will be asked for the credentials
you use to log in to the laptop soon after it starts.

**Logs That May Be Useful**

C:\ProgramData\chocolatey\logs\chocolatey.log

~\AppData\Local\Boxstarter\boxstarter.log 

**Testing**

This script was tested on a VMware VM ("Kim-Test") running Windows 10 (64-bit), and on a similarly 
provisioned laptop (my third Dell).

**Known Bugs**

1. For some reason, Boxstarter's log messages are duplicated. This has been observed by others. I
have not found a solution.
2. If run a second time, the build will, in general, succeed, and stuff that has already been
install will be ignored or updated. Visual Studio Code extensions are an exception, however. They
will be reported as "not found" in error messages like this one:

    ```
    Extension 'wholetomatosoftware.visualassist' not found.
    Make sure you use the full extension ID, including the publisher, e.g.: ms-dotnettools.csharp
    Failed Installing Extensions: wholetomatosoftware.visualassist
    ```

**Additional Work To Do**

There are some things the Build.ps1 script does not do that you may want to do yourself, including:

* update Microsoft Edge
* sign in to your preferred browser(s)
* sign in to OneDrive and/or Google Drive
* sign in to Visual Studio
* sign in to Github Desktop
* add an [Autohotkey](https://www.autohotkey.com/) script to %appdata%\Microsoft\Windows\Start Menu\Programs\Startup
* get the [Postman Agent](https://blog.postman.com/introducing-the-postman-agent-send-api-requests-from-your-browser-without-limits/)
* migrate the user secrets from your old laptop (%appdata%\microsoft\UserSecrets\\microsoft\UserSecrets)

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

[Forest's Autohotkey scripts](https://github.com/forestb/autohotkey-scripts)

[Sean's Autohotkey script](https://gist.github.com/sxmanton/ec91ad6a6fd31a57e7eb152ad837dcb9)

[Forest's ConEmu Cheat Sheet](https://docs.google.com/document/d/13rbTm06QsbGDe4UHbsJlmxMoRh_yKvEJ9vByQxK-VEA)

[Sean's PowerShell shortcuts](https://gist.github.com/sxmanton/f980cbc5fbd660e89c997c069db6fa4f)

[Kim's Introduction to z](https://docs.google.com/document/d/1RrRuwgPh2OVP05fVQT5iUlCkTfJzTpocs7eJckSmGaY)

***Articles About Automating Machine Builds***

https://azuresamurai.blog/2020-11-05-Automating-your-dev-env

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

