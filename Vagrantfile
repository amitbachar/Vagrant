# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$script =<<SCRIPT
echo export http_proxy=genproxy:8080 >> /root/.bashrc
echo export https_proxy=https://genproxy:8080 >> /root/.bashrc
#echo "export FACTER_amd_role_name=\"role::amf1::amf1_simple_single_carbon\"" >> /root/.bashrc


. /root/.bashrc
ifconfig -a | grep "inet "

rpm -q amd_perforce > /dev/null

if [ $? -eq 1 ]
 then
 rpm -ivh /vagrant/amd_perforce-2013-1.x86_64.rpm
fi

tr -d '\r' < /vagrant/amf_clone_win.bash >  /vagrant/amf_clone.bash
tr -d '\r' < /vagrant/p4pciwrapper_win >  /vagrant/p4pciwrapper


/vagrant/amf_clone.bash $1 $2   
#if [ $? -eq 0 ]
# then
# echo "Failed to run amf_clone.bash"
# exit 1
#fi

export AMF_SCRIPTS_DIR="/root/Applications/PCI/EAAS/main/AMF/scripts"
chmod 755 $AMF_SCRIPTS_DIR/amf_build.bash
chmod 755 $AMF_SCRIPTS_DIR/amf_install.bash
chmod 755 $AMF_SCRIPTS_DIR/amf_create_chrome_scripts.bash
 
$AMF_SCRIPTS_DIR/amf_build.bash
$AMF_SCRIPTS_DIR/amf_install.bash
$AMF_SCRIPTS_DIR/amf_create_chrome_scripts.bash

ifconfig -a | grep "inet "
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #Box location 
  #config.vm.box_url = "centos"
  config.vm.box = "centos"
  config.vm.provider "virtualbox" do |v|
      v.memory = 1024
	    file_to_disk = '2nd_disk.vdi'
      v.customize ['createhd', '--filename', file_to_disk, '--size', 15 * 1024]  
      v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
  end
  config.vm.provision :shell, :args => ENV['P4DETAILS'], inline: $script
  config.vm.network "private_network", type: "dhcp"
  config.vm.provider :virtualbox do |vb|
  # Random name will be generated
  #vb.name = "amfvm"
  end


end
