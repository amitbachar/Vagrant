#!/bin/sh
     
# Global Defines
ERROR=1
TRUE=1
FALSE=0

info()
{
	echo "INFO: $@"
}

error()
{
	echo "ERROR: $@"
	exit ${ERROR}
}

printline()
{
	echo "---------------------------------------------------------------------------------------------"
}

die()
{
	printline
	error "Something went terribly wrong !!!"
	printline
	error $@
	printline
	exit ${ERROR}
}
      
     
# install ifconfig
sudo yum install net-tools -y;
# install ansible
sudo yum install ansible -y;
info ansible --version
# install git
sudo yum install -y git || die
# enable ssh login with username and password
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config || die
sudo systemctl restart sshd;
sudo systemctl status sshd;
#ssh-keygen -b 2048 -t rsa -f ~/.ssh/MyCentos7_vagrant_sshkey -q -N "" -C "amit.bachar@gmail.com"
#ssh-keygen -b 2048 -t rsa -f ~/.ssh/sshkey -q -N ""
printline
echo pwd = `pwd`
id
printline
eval $(ssh-agent -s)
ssh-add /vagrant/keys/MyCentos7_vagrant_sshkey
echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $*' > ssh
chmod +x ssh
GIT_SSH="$PWD/ssh" git clone git@github.com:amitbachar/Vagrant.git || die
GIT_SSH="$PWD/ssh" git clone git@github.com:geerlingguy/ansible-role-docker.git || die
#sudo ansible-playbook /vagrant/playbooks/install-docker.yml
printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@`ifconfig -a eth1 | grep "inet " | awk '{print $2}'`
printline
info 'happy vagranting '
