cd ${HOME}/emr_cluster_setup

if command -v apt-get >/dev/null; then
    sudo apt-get install -y git emacs
else
    sudo yum install -y git emacs
fi

#tell git who you are
git config --global user.email "yabebal@gmail.com"
git config --global user.name "Yabebal Fantaye"


curdir=`pwd`

#mount s3 folder
bash mount-s3fs.sh install

#copy cred to current user
bash copy_creds_from_s3mount.sh

#add system users
bash dshub_add_users.sh

#apply mem limit
bash apply_mem_limit.sh


#install miniconda and create algos env
bash new_conda_setup.sh

#setup jupyterhub system
bash install_emr_jupyterhub.sh

#get submodules
#bash git-submodule.sh
git clone https://ab997a2a00f803611fd93a8de968932140572966@github.com/FutureAdLabs/algos-common.git ../algos-common


#install algos-common requirement
cd ../algos-common
source ~/.bashrc
conda activate algos 
conda install pip -y
pip3 install -r requirements_latest.txt
pip3 install -e .

cd $curdir
#sudo python3 -m pip install -r requirements_latest.txt
#sudo python3 -m pip install -e .


#install docker and docker-compose
bash install_docker.sh 
