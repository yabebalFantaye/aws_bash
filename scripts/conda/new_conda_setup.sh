set -e

sudo mkdir -p /opt/jupyterhub
sudo chmod -R 777 /opt/jupyterhub

#get miniconda
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p /opt/jupyterhub/miniconda
rm /tmp/miniconda.sh

cat <<EOF >> ~/.bashrc
export PATH="/opt/jupyterhub/miniconda/bin:${PATH}"
alias pip=/opt/jupyterhub/miniconda/envs/algos/bin/pip3
EOF

source ~/.bashrc
conda init bash
source ~/.bashrc

#update awscli
bash awscli_update.sh

#create venv
conda install -c anaconda -y ipykernel
conda create -n algos -y
conda activate algos

#install common packages
conda install \
      -c conda-forge \
      -y \
      -q \
      numpy pandas boto3 scipy \
      matplotlib seaborn plotly \
      sqlalchemy 
conda install -c anaconda -y ipykernel

