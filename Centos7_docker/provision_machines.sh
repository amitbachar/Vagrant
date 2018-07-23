## withoud docker
#vagrant --hostname=host1.bachar.com provision
#vagrant --hostname=host2.bachar.com provision
#vagrant --hostname=host3.bachar.com provision
## with docker
#SHELL_ARGS='-d -n host1-nginx -p 8080' vagrant --hostname=host1.bachar.com provision
#SHELL_ARGS='-d -n host2-nginx -p 8080' vagrant --hostname=host2.bachar.com provision
#SHELL_ARGS='-d -n host3-nginx -p 8080' vagrant --hostname=host3.bachar.com provision
## with docker and MySql Cluster
SHELL_ARGS='-d -n host1-nginx -p 8080 -m' vagrant --hostname=host1.bachar.com provision
SHELL_ARGS='-d -n host2-nginx -p 8080 -m' vagrant --hostname=host2.bachar.com provision
SHELL_ARGS='-d -n host3-nginx -p 8080 -m' vagrant --hostname=host3.bachar.com provision


