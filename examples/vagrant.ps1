#before Running this program make sure :
# - vagrant is installed  (refer to PCI vagrant guide for further information)
# - centos Box is installed (refer to PCI vagrant guide for further information)
# - perforce clinet is installed 
# Run this script as below :
# option 1 - powershell 
# Run the following command from powersehll admin session ( Right click powershell and run  as admin )
# ./pci_magics.ps1
# option 2 - command line 
# option 2.1 : powershell -ExecutionPolicy ByPass -File ./pci_magics.ps1
# option 2.2   powershell -file ./pci_magics.ps1
#              you might need to run somthing like below (TODO :check correct permissions) :
#		Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted
# Tip : another easier option is to create batch file and attached shortcut key to its shortcut .
# the batch file example is :
#cd C:\pci_all\depot\Applications\PCI\EAAS\main\AMF\scripts
#powershell -ExecutionPolicy ByPass -File ./pci_amf_vagrant.ps1
#pause

$env:P4PORT = "10.232.165.229:1666"
#TODO : take from env vars ProgramFiles(x86)
$chrome_path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$chrome_script = "openchrome.bat"
$win_default_user = [Environment]::UserName.ToLower()



$perforce_user = Read-Host "Please insert perforce user [$win_default_user] "

if ( $perforce_user -eq "" )
{
$perforce_user = $win_default_user
}



$perforce_password_crypt = Read-Host "Please insert perforce password" -AsSecureString

# we send vagrant password 
$perforce_password=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($perforce_password_crypt ))

$vagrant_dir_date =  Get-Date -format dMyyyy.hhmmss
$vagrant_dir_def = "c:\vagrant\vagrant_" + $vagrant_dir_date

$vagrant_dir = Read-Host "Please type vagrant directory [$vagrant_dir_def] "

if ( $vagrant_dir -eq "" )
{
#Write-Host "Setting vagrant directory to $vagrant_dir" -ForegroundColor Green
$vagrant_dir = $vagrant_dir_def 
}


$run_chrome = Read-Host "Do you want to to start chrome after installation Y/N ? [Y]"

if(!(Test-Path -Path $vagrant_dir )){
    Write-Host "Creating directory $vagrant_dir" -ForegroundColor Green
    new-item $vagrant_dir -itemtype directory
}
else 
{
    Write-Host "Using directory $vagrant_dir" -ForegroundColor Green
}

# for vagrant file 
$env:P4DETAILS = "$win_default_user $perforce_password"

$env:P4USER = "$win_default_user"

Set-Location $vagrant_dir
p4 print -o p4pciwrapper_win //depot/Applications/PCI/EAAS/main/core/scripts/p4pciwrapper
p4 print -o amf_clone_win.bash //depot/Applications/PCI/EAAS/main/AMF/scripts/amf_clone.bash
p4 print -o Vagrantfile //depot/Applications/PCI/EAAS/main/AMF/scripts/Vagrantfile
p4 print -o amd_perforce-2013-1.x86_64.rpm //depot/Applications/PCI/EAAS/main/core/perforce_rpm/amd_perforce-2013-1.x86_64.rpm



# in vagrant file we should have
# config.vm.provision :shell, :args => ENV['P4DETAILS'], inline: $script
$scriptblock = {vagrant up}
&Invoke-Command -scriptblock $scriptblock 

$chrome_script_path = $vagrant_dir + "\" +$chrome_script
Write-Host "Executing $chrome_script_path ..." -ForegroundColor Green

#starting chrome session 
If ((Test-Path "$chrome_path") -and (($run_chrome -eq "Y") -or ($run_chrome -eq "")) ){
   start-process "$chrome_script_path"
}

Write-Host "installation finished successfully " -ForegroundColor Blue

Start-Sleep -s 1200