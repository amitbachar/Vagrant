## withoud docker
#vagrant --hostname=host1.bachar.com -- destroy --force
#vagrant --hostname=host2.bachar.com -- destroy --force
#vagrant --hostname=host3.bachar.com -- destroy --force
#with Docker 
#SHELL_ARGS='-d -n host1-nginx -p 8080' vagrant --hostname=host1.bachar.com -- destroy
#SHELL_ARGS='-d -n host2-nginx -p 8080' vagrant --hostname=host2.bachar.com -- destroy
#SHELL_ARGS='-d -n host3-nginx -p 8080' vagrant --hostname=host3.bachar.com -- destroy
## with docker and MySql
SHELL_ARGS='-d -n host1-nginx -p 8080 -m' vagrant --hostname=host1.bachar.com -- destroy
SHELL_ARGS='-d -n host2-nginx -p 8080 -m' vagrant --hostname=host2.bachar.com -- destroy
SHELL_ARGS='-d -n host3-nginx -p 8080 -m' vagrant --hostname=host3.bachar.com -- destroy

