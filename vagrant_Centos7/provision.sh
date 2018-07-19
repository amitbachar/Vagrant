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
info pwd
info id
# copy ssh keys for git clone
#if [ ! -d ~vagrant/.ssh ]
#then
#   mkdir ~vagrant/.ssh
#fi
#sudo -u vagrant cp /vagrant/.ssh/MyCentos7_vagrant_sshkey ~vagrant/.ssh 
#sudo -u vagrant cp /vagrant/.ssh/MyCentos7_vagrant_sshkey.pub ~vagrant/.ssh
#chmod 400 ~vagrant/.ssh/MyCentos7_vagrant_sshkey*
eval $(ssh-agent -s)
ssh-add /vagrant/.ssh/MyCentos7_vagrant_sshkey
#tee -a c << END
#Host github.com
#      StrictHostKeyChecking no
#      UserKnownHostsFile=/dev/null
#END
touch ~vagrant/.ssh/config
cat << EOF >> ~vagrant/.ssh/config
  Host github.com
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF
chmod 400 ~vagrant/.ssh/config
git clone git@github.com:amitbachar/Vagrant.git || die
printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@`ifconfig -a eth1 | grep "inet " | awk '{print $2}'`
printline
info 'happy vagranting '
