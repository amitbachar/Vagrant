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

#!/bin/bash

init()
{
	install_docker=no
	nginx_name=bibi-nginx
	nginx_port=8080
	install_mysql_cluster=no
}

function usage 
{
  echo ""
   echo "Usage: $0 [--nginx_name string] [--nginx_port integer] [--install_docker bool]  [--install_mysql_cluster bool] [--http_proxy string]"

   echo ""
   echo "If some parameter is not set default values will be used"
   echo ""
   echo "Example:"
   echo "$0  --nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://myproxyhost:8080"
   echo ""
}


function checkParameterValue
{
    if [[ -z $2 ]]
    then
      echo ""
      echo "ERROR: Value for parameter ${1} is missing"
      usage
      exit 2
     fi
}

function checkParameters
{

  while test $# -ne 0
  do
     case $1 in
        --nginx_name)
          checkParameterValue $1 $2
         export nginx_name="$2"
         echo "nginx_name ==> $nginx_name"
         shift 2
        ;;
        --nginx_port)
          checkParameterValue $1 $2
         export nginx_port="$2"
         echo "nginx_port ==> $nginx_port"
         shift 2
        ;;
        --install_docker)
          checkParameterValue $1 $2
         export install_docker="$2"
         echo "install_docker ==> $install_docker"
         shift 2
        ;;
        --install_mysql_cluster)
          checkParameterValue $1 $2
         export install_mysql_cluster="$2"
         echo "install_mysql_cluster ==> $install_mysql_cluster"
         shift 2
        ;;
        --http_proxy)
           checkParameterValue $1 $2
           export http_proxy="$2"
           echo "http_proxy ==> $http_proxy"
           shift 2
  	    ;;
        -h)
           usage
           exit 0
        ;;
        *)
           echo ""
           echo "ERROR: unknown option $1"
           usage
           exit 1
        ;;
     esac
  done
}


install_3rd_party()
{    
# update all yum packages
#yum update -y     
# install ifconfig
if [[ ! -z $http_proxy ]]
then
	export http_proxy=${http_proxy}
	export https_proxy=${http_proxy}
	env | grep http_proxy
	grep -qF -- "proxy=${http_proxy}" /etc/yum.conf || echo "proxy=${http_proxy}" >> /etc/yum.conf
	#echo proxy=${http_proxy} >> /etc/yum.conf
	cat /etc/yum.conf
fi
sudo yum install net-tools -y;
# install ansible
sudo yum install ansible -y;
info ansible --version
# install git
sudo yum install -y git || die
git config --global user.email "amit.bachar@gmail.com" || die
git config --global user.name "Amit Bachar" || die
if [[ ! -z $http_proxy ]]
then
	git config --global http.proxy ${http_proxy}
	git config --global https.proxy ${http_proxy}
fi

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" || die
python get-pip.py || die
# enable ssh login with username and password
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config || die
sudo systemctl restart sshd;
sudo systemctl status sshd;

# updating hosts file with server external IP
extIP=`ifconfig -a eth1 | grep "inet " | awk '{print $2}'`
HOST=`hostname`
sed -i "/$HOST/ s/.*/$extIP\t$HOST/g" /etc/hosts

printline
echo pwd = `pwd`
id
echo arguments = $@
printline
echo HOST = $HOST
echo External IP = extIP
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
#git clone git@github.com:amitbachar/Vagrant.git || die
git clone https://github.com/amitbachar/Vagrant.git || die
}

install_docker()
{
	# downloading docker ansible role from git
	if [ -d /vagrant/playbooks/roles/ansible-role-docker ]
	then
		rm -rf /vagrant/playbooks/roles/ansible-role-docker 
	fi
	mkdir -p /vagrant/playbooks/roles/ansible-role-docker
	#GIT_SSH="$PWD/ssh" git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die
	#git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die
	git clone https://github.com/geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die

	# Installing docker via ansible
	cd /vagrant/playbooks/
	sed -i "s/ansible_host=host1.bachar.com/ansible_host=${HOST}/g" inventories/docker-inventory 
	ansible-playbook -i inventories/docker-inventory install-docker.yml -vv || die

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
}

install_MySql_Cluster()
{
	# install the pip docker for the ansible run
	pip install docker || die
	# downloading docker ansible role from git
	if [ -d /vagrant/playbooks/roles/MySQL-cluster ]
	then
		rm -rf /vagrant/playbooks/roles/MySQL-cluster 
	fi
	#mkdir -p /vagrant/playbooks/roles/ansible-role-docker
	#GIT_SSH="$PWD/ssh" git clone git@github.com:geerlingguy/ansible-role-docker.git /vagrant/playbooks/roles/ansible-role-docker || die
	#git clone git@github.com:amitbachar/MySQL-cluster.git /vagrant/playbooks/roles/MySQL-cluster || die
	git clone https://github.com/amitbachar/MySQL-cluster.git /vagrant/playbooks/roles/MySQL-cluster || die
	# Installing MySql Cluster via ansible
	cd /vagrant/playbooks/
	sed -i "s/ansible_host=host1.bachar.com/ansible_host=${HOST}/g" inventories/mqsql-cluster-inventory 
	ansible-playbook -i inventories/mqsql-cluster-inventory mqsql-cluster.yml -vv || die
}

# M A I N
init


#while getopts ":n:p:dm" opt; do
#    case "$opt" in
#        n)
#            nginx_name="$OPTARG"
#            echo $nginx_name 
#            ;;
#        p)
#            nginx_port="$OPTARG"
#            echo $nginx_port 
#            ;;
#        d)
#            install_docker="yes"
#            echo $install_docker 
#            ;;
#        m)
#            install_mysql_cluster="yes"
#            echo $install_docker 
#            ;;
#    esac
#done


checkParameters $*
install_3rd_party
echo "install_docker => $install_docker"
if [ $install_docker == yes ]
then
	install_docker
	# MySql Cluster will get installed only when docker will get installed
	echo "install_mysql_cluster => $install_mysql_cluster"
	if [ $install_mysql_cluster == yes ]
	then
		install_MySql_Cluster
	fi
fi

printline
ifconfig -a | grep "inet ";
printline
info ssh vagrant@${extIP}
printline
info 'happy vagranting '
