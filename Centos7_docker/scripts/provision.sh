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

install_docker=no
nginx_name=bibi-nginx
nginx_port=8080

while getopts ":n:p:da" opt; do
    case "$opt" in
        n)
            nginx_name="$OPTARG"
            echo "nginx_name => $nginx_name" 
            ;;
        p)
            nginx_port="$OPTARG"
            echo "nginx_port => $nginx_port" 
            ;;
        d)
            install_docker="yes"
            echo "install_docker => $install_docker"
            ;;
        a)
            echo export http_proxy=genproxy:8080 >> /root/.bashrc
	    echo export https_proxy=https://genproxy:8080 >> /root/.bashrc
            echo proxy=http://genproxy:8080 >> /etc/yum.conf
            #export http_proxy=http://genproxy:8080/
            #echo "http_proxy => $http_proxy"
            #export https_proxy=https://genproxy:8080/
            #echo "https_proxy => $https_proxy"
            ;;
    esac
done


# update all yum packages
#yum update -y     
# install ifconfig
yum install net-tools -y;

# updating hosts file with server external IP
extIP=`ifconfig -a eth1 | grep "inet " | awk '{print $2}'`
HOST=`hostname`
sed -i "/$HOST/ s/.*/$extIP\t$HOST/g" /etc/hosts
printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@${extIP}
printline

# install ansible
yum install ansible -y;
info ansible --version
# install git
yum install -y git || die
# enable ssh login with username and password
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config || die
systemctl restart sshd;
systemctl status sshd;

printline
echo pwd = `pwd`
id
echo arguments = $@
printline
echo HOST = $HOST
echo External IP = $extIP
printline

#ssh-keygen -b 2048 -t rsa -f ~/.ssh/MyCentos7_vagrant_sshkey -q -N "" -C "amit.bachar@gmail.com"
#ssh-keygen -b 2048 -t rsa -f ~/.ssh/sshkey -q -N ""
# set passwordless ssh keys for ansible run for root and for vagrant users
sudo -u vagrant ssh-keygen -b 2048 -t rsa -f ~vagrant/.ssh/id_rsa -q -N ""
sudo -u vagrant cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys ; chmod 640 ~vagrant/.ssh/authorized_keys
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N "" 
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys ; chmod 640 /root/.ssh/authorized_keys
#cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

tee -a .ssh/config << END
Host github.com $HOST localhost
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
END
chmod 400 .ssh/config
chown vagrant:vagrant .ssh/config
cp .ssh/config /root/.ssh/config
chmod 400 /root/.ssh/config

# add the git ssh private key to the ssh daemon
eval $(ssh-agent -s)
chmod 400 /vagrant/keys/MyCentos7_vagrant_sshkey
ssh-add /vagrant/keys/MyCentos7_vagrant_sshkey
#if [ -f ssh]
#then
#	rm -f ssh
#fi
#echo 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $*' > ssh
#chmod +x ssh
if [ -d Vagrant ]
then
	rm -rf Vagrant
fi
#GIT_SSH="$PWD/ssh" git clone git@github.com:amitbachar/Vagrant.git || die
git clone git@github.com:amitbachar/Vagrant.git || die

echo "install_docker => $install_docker"
if [ $install_docker == yes ]
then
	# downloading docker ansible role from git
	if [ -d /vagrant/playbooks/roles/ansible-role-docker ]
	then
		rm -rf /vagrant/playbooks/roles/ansible-role-docker 
	fi
	mkdir -p /vagrant/playbooks/roles/ansible-role-docker
	#GIT_SSH="$PWD/ssh" git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die
	git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die

	# Installing docker via ansible
	cd /vagrant/playbooks/
	sed -i "s/ansible_host=host1.bachar.com/ansible_host=${HOST}/g" inventory 
	ansible-playbook -i inventory install-docker.yml -vv || die

	# testing docker installation by running nginx container
	docker run --name ${nginx_name} -d -p ${nginx_port}:80 nginx
	docker ps
	nginx_test=`curl -s -o /dev/null -w "%{http_code}" http://localhost:${nginx_port}`
	if [ $nginx_test == 200 ] 
	then
		info "bibi-nginx installed succsesfully"
	else
		info "bibi-nginx return status : $nginx_test"
	fi
fi
printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@${extIP}
printline
info 'happy vagranting '
