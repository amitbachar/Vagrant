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
      
# update all yum packages
yum update -y     
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
tee -a .ssh/config << END
Host github.com
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
END
chmod 400 .ssh/config
printline
echo pwd = `pwd`
id
printline
eval $(ssh-agent -s)
chmod 400 /vagrant/keys/MyCentos7_vagrant_sshkey
ssh-add /vagrant/keys/MyCentos7_vagrant_sshkey
#if [ -f ssh]
#then
#	rm -f ssh
#fi
echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $*' > ssh
chmod +x ssh
if [ -d Vagrant ]
then
	rm -rf Vagrant
fi
GIT_SSH="$PWD/ssh" git clone git@github.com:amitbachar/Vagrant.git || die
# set passwordless ssh keys for ansible run
#sudo -u vagrant ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
#sudo -u vagrant cat .ssh/id_rsa.pub >> .ssh/authorized_keys ; chmod 640 .ssh/authorized_keys
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" 
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys ; chmod 640 /root/.ssh/authorized_keys
#cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# downloading docker ansible role from git
if [ -d /vagrant/playbooks/roles/ansible-role-docker ]
then
	rm -rf /vagrant/playbooks/roles/ansible-role-docker 
fi
mkdir -p /vagrant/playbooks/roles/ansible-role-docker
GIT_SSH="$PWD/ssh" git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die

# updating hosts file with server external IP
extIP=`ifconfig -a eth1 | grep "inet " | awk '{print $2}'`
HOST=`hostname`
sed -i "/$HOST/ s/.*/$extIP\t$HOST/g" /etc/hosts

# Installing docker via ansible
cd /vagrant/playbooks/ 
ansible-playbook -i inventory install-docker.yml -vv || die

# testing docker installation by running nginx container
docker run --name bibi-nginx -d -p 8080:80 nginx
docker ps
nginx_test=`curl -s -o /dev/null -w "%{http_code}" http://localhost:8080`
if [ $nginx_test == 200 ] 
then
	info "bibi-nginx installed succsesfully"
else
	info "bibi-nginx return status : $nginx_test"
fi
printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@${extIP}
printline
info 'happy vagranting '
