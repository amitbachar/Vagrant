# Vagrant
```
provision Centos7 machine with the option to istall
1. Docker
2. MySql Cluster
```


## Usage 

```
Create new Vagrant Machine:
SHELL_ARGS='--nginx_name string --nginx_port integer --install_docker yes/no --install_mysql_cluster yes/no' vagrant --hostname=<virtual machine desire host name> -- up

Peovisioning:
SHELL_ARGS='--nginx_name string --nginx_port integer --install_docker yes/no --install_mysql_cluster yes/no' vagrant --hostname=<virtual machine desire host name> -- provision

Delete:
vagrant --hostname=<virtual machine host name> -- destroy

provision.sh script Usage:

Usage: $0 [--nginx_name string] [--nginx_port integer] [--install_docker bool]  [--install_mysql_cluster bool] [--http_proxy string]"



 SHELL_ARGS are optional if not pass use Default Values :

	install_docker=no
	nginx_name=bibi-nginx
	nginx_port=8080
	install_mysql_cluster=no
```

## Examples :

```
Example for creating virtual machine : 
With Docker without MySql - 
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes' vagrant --hostname=host22.bachar.com -- up
With Docker and MySql -
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster no' vagrant --hostname=host22.bachar.com -- up
With Docker and MySql behind proxy -
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host22.bachar.com -- up

Example for provisioning virtual machine : 

With Docker without MySql - 
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes' vagrant --hostname=host22.bachar.com -- provision
With Docker and MySql - 
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster no' vagrant --hostname=host22.bachar.com -- provision
With Proxy - 
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host22.bachar.com -- provision

Example for Erasing virtual machine : 

vagrant --hostname=host22.bachar.com -- destroy --force

```
