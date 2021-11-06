status="$(systemctl is-active jupyterhub)"
if [ ! "${status}" = "active" ]; then
    sudo sh -c "systemctl start jupyterhub"
fi

if [ ! -d "/mnt/10ac-batch-4/credentials" ]; then
    sudo sh -c "chmod u+x /home/ec2-user/trainees_aws_cluster/scripts/s3mount/mount-s3fs.sh"
    sudo sh -c "/home/ec2-user/trainees_aws_cluster/scripts/s3mount/mount-s3fs.sh"
fi
