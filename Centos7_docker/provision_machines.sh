## withoud docker
#vagrant --hostname=host1.bachar.com provision
#vagrant --hostname=host2.bachar.com provision
#vagrant --hostname=host3.bachar.com provision
## with docker
#SHELL_ARGS='-d -n host1-nginx -p 8080' vagrant --hostname=host1.bachar.com provision
#SHELL_ARGS='-d -n host2-nginx -p 8080' vagrant --hostname=host2.bachar.com provision
#SHELL_ARGS='-d -n host3-nginx -p 8080' vagrant --hostname=host3.bachar.com provision
## with docker and MySql Cluster
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes' vagrant --hostname=host22.bachar.com -- provision
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster no' vagrant --hostname=host22.bachar.com -- provision
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host22.bachar.com -- provision


