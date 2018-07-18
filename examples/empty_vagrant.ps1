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
#cd C:\eaas\Applications\PCI\EAAS\main\AMF\scripts
#powershell -ExecutionPolicy ByPass -File ./pci_gen_vagrant_amf.ps1
#pause

# Below is example for "Please type perforce workspace root dir"
# The directory application must be exist under c:\[something] 
# ie c:\eaas 
#Workspace name:C:\EAAS
#Workspace root :C:\EAAS
#
#-//depot/... //EAAS/...
#//depot/Applications/PCI/EAAS/... //EAAS/Applications/PCI/EAAS/...



clear
Write-Host "Welcome to PCI vagrant wrapper " -ForegroundColor Blue

$env:P4PORT = "10.232.165.229:1666"
$chrome_path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$chrome_script = "openchrome.bat"
$Vagrantfile_template = "Vagrantfile_template_amf"
$proxy_short_url = "genproxy:8080"
$https_proxy = "https://" + $proxy_short_url
$http_proxy = "http://" + $proxy_short_url
$install_dir = "/root/Applications/PCI/EAAS/main/AMF/scripts/"
$perforce_workspace_dir_linux =  "/root/Applications"
$puppet_role_name = "amf1::amf1_simple_single_carbon"
$pci_scripts_dir = "PCI\EAAS\main\AMF\scripts"


$win_default_user = [Environment]::UserName.ToLower()

##########################################


$use_puppet_role = Read-Host "Please insert puppet role [click enter for $puppet_role_name ] "
if ( $use_puppet_role -ne "" )
{
 $puppet_role_name = "use_puppet_role"
}

 $role_message = "Using puppet role role::" + $puppet_role_name
 Write-Host  $role_message -ForegroundColor Green 

 
 ##########################################
$vagrant_dir_date =  Get-Date -format dMyyyy.hhmmss
$vagrant_dir_def = "c:\vagrant\vagrant_" + $vagrant_dir_date
$vagrant_dir = Read-Host "Please enter vagrant directory [click Enter for $vagrant_dir_def] "
if ( $vagrant_dir -eq "" )
{
#Write-Host "Setting vagrant directory to $vagrant_dir" -ForegroundColor Green
$vagrant_dir = $vagrant_dir_def 
}
if(!(Test-Path -Path $vagrant_dir )){
    new-item $vagrant_dir -itemtype directory  | Out-Null
   Write-Host "Directory $vagrant_dir created successfully" -ForegroundColor Green
  
}
else 
{
    Write-Host "Using directory $vagrant_dir" -ForegroundColor Green
}


####################################


 $use_proxy_input = Read-Host "Do you want to use http proxy [click Enter for Y] "
if ( $use_proxy_input -eq "" )
{
 $use_http_proxy = "Yes"
   Write-Host "Using proxy $proxy_short_url" -ForegroundColor Green
 
}
else
{
  $use_http_proxy = "No"
} 
 
 ########################################
$run_chrome = Read-Host "Do you want to to start chrome after installation Y/N ? [Y]"

##########################################

$running_mode = Read-Host "Do you want to use sources from perforce ?[click Enter for N]"
if ( $running_mode -eq "" )
{
  $use_perforce = "no"
  Write-Host "Using workspace files ..." -ForegroundColor Green 
  Set-Location $vagrant_dir
  #$env:SRC_SHARED_FOLDER = "/root/Applications"
}
else
{
	$perforce_user = Read-Host "Please insert perforce user [$win_default_user] "
	if ( $perforce_user -eq "" )
	{
		$perforce_user = $win_default_user
	}
	$perforce_password_crypt = Read-Host "Please insert perforce password" -AsSecureString
	# we send vagrant password 
	$perforce_password=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($perforce_password_crypt ))
	
	# for vagrant file 
	#$env:SRC_SHARED_FOLDER = "/src"
	$env:P4DETAILS = "$win_default_user $perforce_password"
	$env:P4USER = "$win_default_user"
	Set-Location $vagrant_dir
	p4 print -o p4pciwrapper_win //depot/Applications/PCI/EAAS/main/core/scripts/p4pciwrapper
	p4 print -o amf_clone_win.bash //depot/Applications/PCI/EAAS/main/AMF/scripts/amf_clone.bash
	p4 print -o Vagrantfile //depot/Applications/PCI/EAAS/main/AMF/scripts/Vagrantfile
	p4 print -o amd_perforce-2013-1.x86_64.rpm //depot/Applications/PCI/EAAS/main/core/perforce_rpm/amd_perforce-2013-1.x86_64.rpm
}
########################################

##########################################
# For Vagrant file  - todo make it better :

if ( $use_perforce -eq "no" )
{

	$local_drive = "C:\"
	$windows_workspace_root = "eaas"
	
	Write-Host "Please type perforce workspace root dir:" 
	Write-Host "[click Enter for $windows_workspace_root]  " 
	 $use_windows_workspace_root = Read-Host "Please note - using default require directory C:\eaas\Applications "
	
	
	if ( $use_windows_workspace_root -ne "" )
	{
	 $windows_workspace_root = $use_windows_workspace_root
	 Write-Host "Using workspace dir $windows_workspace_root" -ForegroundColor Green
	}
	
	$scripts_dir = $local_drive +  $windows_workspace_root + "\Applications\" + $pci_scripts_dir
	$perforce_workspace_dir_windows =  $local_drive + "\"  + $windows_workspace_root + "\\Applications"
	
	
	## Generate the vagrant from template
	$lookupTable = @{
	'TOKEN_PROXY_SHORT_URL' = $proxy_short_url 
	'TOKEN_ROLE_NAME' = $puppet_role_name 
	'TOKEN_PERFORCE_WORKSPACE_DIR_LINUX' = $perforce_workspace_dir_linux 
	'TOKEN_PERFORCE_WORKSPACE_DIR_WIN' = $perforce_workspace_dir_windows 
	'TOKEN_USE_HTTP' = $use_http_proxy
	}
	
	
	$original_file = $scripts_dir + "\" + $Vagrantfile_template
	$destination_file = $vagrant_dir+ "\" + "Vagrantfile"
	
	Write-Host "Generating file $destination_file " -ForegroundColor Green
	Get-Content -Path $original_file | ForEach-Object { 
	    $line = $_
	
	    $lookupTable.GetEnumerator() | ForEach-Object {
	        if ($line -match $_.Key)
	        {
	            $line = $line -replace $_.Key, $_.Value
	        }
	    }
	   $line
	} | Set-Content -Path $destination_file

}





# in vagrant file we should have
# config.vm.provision :shell, :args => ENV['P4DETAILS'], inline: $script
$scriptblock = {vagrant up}
&Invoke-Command -scriptblock $scriptblock 

$chrome_script_path = $vagrant_dir + "\" +$chrome_script
Write-Host "Executing $chrome_script_path ..." -ForegroundColor Green

#starting chrome session 
If ((Test-Path "$chrome_path") -and (($run_chrome -eq "Y") -or ($run_chrome -eq "")) ){
  
  if (Test-Path "$chrome_script_path")
   {
   start-process "$chrome_script_path"
   }
  else 
  {
   Write-Host "Can not find  $chrome_script_path ..." -ForegroundColor Red
   Write-Host "script should be generated with vagrant up command " 
  }
   
}

Write-Host "installation finished successfully " -ForegroundColor Blue

Start-Sleep -s 1200