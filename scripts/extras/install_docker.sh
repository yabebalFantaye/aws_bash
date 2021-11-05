home=${ADMIN_HOME:-$(ls /home | awk 'NR==1{print $1}')}
if [ -d $home ]; then
    homeUser=$home
else
    homeUser=`whoami`
fi
if command -v docker >/dev/null; then
	echo "docker is already installed"
else
    echo "installing docker .."
    if command -v apt-get >/dev/null; then
	sudo apt-get update -y
	sudo apt-get install -y docker
	sudo service docker start
	sudo usermod -a -G docker ${homeUser}
	
    elif command -v yum >/dev/null; then
	sudo yum update -y
	sudo yum install -y docker
	sudo service docker start
	sudo usermod -a -G docker ${homeUser}
    else
	echo "unknown os system.."
	exit
    fi
fi

if command -v docker-compose >/dev/null; then
	echo "docker-compose is already installed"
else
    echo "installing docker-compose .."
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

docker --version
docker-compose --version

if [ -d user ]; then
    cd user
    if [ $# -gt 0 ]; then
        userfile=$1
    else
        userfile=${USERS_FILE:-"users.txt"}
    fi

    sudo groupadd docker || echo "docker user already exists"
    if [ -f users.txt ] && [ $userfile != "users.txt" ]; then
	echo "adduing users.txt content to  $userfile"
	cat users.txt >> $userfile
    fi

    for n in `cat $userfile`; do
	if [ -d "/home/$n" ]; then
            echo "adding user=$n to docker group .."
            sudo usermod -aG docker $n || echo "user $n already in docker group"
	fi
    done
    sudo systemctl restart docker
    sudo systemctl restart containerd
    
fi
