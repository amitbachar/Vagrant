## withoud docker
#vagrant --hostname=host1.bachar.com up
#vagrant --hostname=host2.bachar.com up
#vagrant --hostname=host3.bachar.com up
## with docker
#SHELL_ARGS='-d -n host1-nginx -p 8080' vagrant --hostname=host1.bachar.com up
#SHELL_ARGS='-d -n host2-nginx -p 8080' vagrant --hostname=host2.bachar.com up
#SHELL_ARGS='-d -n host3-nginx -p 8080' vagrant --hostname=host3.bachar.com up
## with docker and MySql Cluster
SHELL_ARGS='-d -n host1-nginx -p 8080 -m' vagrant --hostname=host1.bachar.com up
SHELL_ARGS='-d -n host2-nginx -p 8080 -m' vagrant --hostname=host2.bachar.com up
SHELL_ARGS='-d -n host3-nginx -p 8080 -m' vagrant --hostname=host3.bachar.com up

SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host1.bachar.com up
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host2.bachar.com up
SHELL_ARGS='--nginx_name my-nginx --nginx_port 8080 --install_docker yes --install_mysql_cluster yes --http_proxy http://genproxy:8080' vagrant --hostname=host3.bachar.com up


