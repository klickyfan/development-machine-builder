# development-machine-builder

This repo contains the components needed to set up a new Windows 10 laptop as [recommended by Seal
Pod](https://levelup.atlassian.net/wiki/spaces/POS/pages/299532297/Chapter+6+Tools) (for Seal Pod
project development). Most important of these components is Build.ps1, a PowerShell script that 
performs all the steps needed. This should not be run directly, however, but rather by running 
KickOffBuild.ps1, which uses [Boxstarter](www.boxstarter.org), an open source tool that detects 
whether a reboot is required during the execution of a PowerShell Script, forces the reboot, and
then relogs you in and resumes the script after the reboot. Hopefully it will prove useful both to
new hires and to and those whose Dells have failed us.

**Usage Instructions**

1. Determine if the new laptop is in need of Windows Updates, and reboot it if so.

2. Download a zip file containing this repo onto your desktop via
   [this url](https://codeload.github.com/klickyfan/development-machine-builder/zip/main) and
   unzip. (Getting it this way does not require git.)

3. Copy settings.template.json to settings.json and then edit settings.json as follows:

    1. Add values for these three variables:

       `gitconfig_user_name` : The username you want associated with all your commits.
       
       `gitconfig_user_email` : The email address you want associated with all your commits.
       
       `gitconfig_github_user` : Your Github user name.
       
    2. Revise the lists of packages and extensions as desired. 
    
       Information about Chocolatey packages can be found
       [here](https://community.chocolatey.org/packages).

       Information about PowerShell packages can be found
       [here](https://www.powershellgallery.com/packages).

       Information about Visual Studio and Visual Studio Code extensions can be found
       [here](https://marketplace.visualstudio.com).

       To list all appx packages ("crap" applications you may want the script to remove):
       ```
       Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
       ```
    
    3. If you want to install Postgres, add these lines, with the password you'd like, at the end
       of the list of Chocolatey packages, 

        ```
       {
          "name": "postgres"
          "parameters": "/Password:<the Postgres password you desire>"
       }
       ```
       
       These lines aren't in settings.template.json because of the need for a password.

       When you are done the JSON should look something like this:
       
       ![image](https://user-images.githubusercontent.com/43219689/137993008-b786594b-8f06-469e-b88e-a5d660448f16.png)
       
       If, by the way, you don't provide the password parameter, a password will be chosen for you.
       You can change it by following the steps listed [here](https://community.chocolatey.org/packages/postgresql).
   
    4. Use a tool like [JSONLint](https://jsonlint.com) to make sure your settings.json file has no errors.
    
4. Modify other configuration files in this repo as desired, either manually or by copying the ones on your
   old laptop from these locations:
   
   * ConEmu.xml: %appdata%<br>
   * .gitconfig: ~\.gitconfig<br>
   * .Nuget.Config %appdata%\NuGet<br>
   * Microsoft.PowerShell_profile.ps1: ~\Documents\WindowsPowerShell<br>
   * Visual Studio Code settings.json: %appdata\Code\User<br>
 
5. Run the PowersShell ISE (already installed) as an administrator and then do the following:

   1. Set the new laptop's ExecutionPolicy from Restricted to Unrestricted). (You can set it back
   after.)
   
   2. Load KickOffBuild.ps1.
   
   3. Press the "Run" button.

7. Stick around to do occasional babysitting. More on this below.

**Babysitting Not Required... Much**

After asking you for the credentials you use to log in to the laptop, the build should run
independently. It should even log you back in and resume after a reboot. And indeed, I have seen
this work on the VM I tested with, but also seen it fail on my own laptop. If this fails for you,
log in, but then wait a few seconds, and you should see the script resume.

**Editing Build.ps1**

If you want to make a change to Build.ps1, you may be tempted to make it in the version that came
in the package you downloaded in step 2 above. This will not work. Boxstarter is using the version
in the main branch of this repo.

**Logs That May Be Useful**

C:\ProgramData\chocolatey\logs\chocolatey.log

~\AppData\Local\Boxstarter\boxstarter.log 

**Testing**

This script was tested on a VMware VM ("Kim-Test") running Windows 10 (64-bit), and on a similarly 
provisioned laptop (my third Dell).

**Known Bugs/Issues**

1. For some reason, Boxstarter's log messages are duplicated. This has been observed by others. I
have not found a solution.

2. As I said above, sometimes Boxstarter's login feature doesn't work. Boxstarter claims to have
resolved this but I nonetheless ran into it.

3. I have twice observed Sentinel One complain about suspicious activity on the machine and clobber
the build. If that occurs, restart it. It can be run multiple times with no harm done.

**Additional Miscellaneous Set Up**

There are some things the Build.ps1 script does not do that you may want to do yourself, including:

* update Microsoft Edge and other software already installed on the machine
* set up printing
* sign in to various places (your preferred browser(s), OneDrive and/or Google Drive, Visual Studio, 
and Github Desktop)
* add an [Autohotkey](https://www.autohotkey.com/) script to %appdata%\Microsoft\Windows\Start Menu\Programs\Startup
* get the [Postman Agent](https://blog.postman.com/introducing-the-postman-agent-send-api-requests-from-your-browser-without-limits/)
* migrate the user secrets from your old laptop (%appdata%\microsoft\UserSecrets\\microsoft\UserSecrets)

**Additional Set Up For Development with Azure**

1. Get the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli). 

2. Run the Azure Command Prompt.

   1. Enter `az login` and enter your credentials.
   
   2. Enter `az account show` and note the values of `id` and `tenant_id`.
   
3. Set the environment variable AZURE_CLIENT_ID to the value of `id` and AZURE_TENANT_ID to the
   value of the variable `tenant_id`.
   
4. Restart Visual Studio.
   
5. Set up Azure Service Authentication in Visual Studio (Tools->Options->Azure Service Authentication).

**Additional Notes and Resources**

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

