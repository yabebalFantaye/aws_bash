#!/bin/bash 
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

region="eu-west-1"

home=$HOME

if command -v apt-get >/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y git emacs htop
    if [ -d /home/ubuntu ]; then
        home=/home/ubuntu
    fi
else
    sudo yum update -y 
    sudo yum install -y git emacs htop
    if [ -d /home/centos ]; then
        home=/home/centos
    fi
    if [ -d /home/ec2-user ]; then
        home=/home/ec2-user
    fi    
fi

if [ -d /home/hadoop ]; then
    home=/home/hadoop
fi

#-------add ADMIN_HOME to be non-root admin
echo "export ADMIN_HOME=$home" >> ~/.bashrc
source ~/.bashrc


#--------tell git who you are
git config --global user.email "yabebal@gmail.com"
git config --global user.name "Yabebal Fantaye"

#--------update aws cli
pip3 install botocore --upgrade || echo "unable to upgrade botocore"
function awscli_install(){
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --update
    if [ -f /usr/bin/aws]; then
        sudo rm /usr/bin/aws || echo "unable to remove aws"
    fi    
    sudo ln -s /usr/local/bin/aws /usr/bin/aws
    rm -rf .aws
}
if [[ $(aws --version) = aws-cli/1.* ]]; then
    awscli_install  || echo "unable to install cli"
fi

#----------get git packages
token=$(aws secretsmanager get-secret-value \
    --secret-id git_token_b4 \
    --query SecretString \
    --output text --region $region  | cut -d: -f2 | tr -d \"})
                                             

cd $home
git clone https://$token@github.com/10xac/trainees_aws_cluster.git

cd trainees_aws_cluster/scripts
bash setup_cluster.sh b4_group1_vars.txt

#change approperiately 
# reqfolder=satellite-lidar
# envname=agritech
# if [ -f $home/trainees_aws_cluster/$reqfolder/install_packages.sh ]; then
#     cd $home/trainees_aws_cluster/$reqfolder
#     bash install_packages.sh $envname
# fi

#copy all root environment to user
if [ -f $HOME/.bashrc ]; then
    cat $HOME/.bashrc >> $home/.bashrc || echo "not possible"
fi
