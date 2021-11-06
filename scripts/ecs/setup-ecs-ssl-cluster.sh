#!/usr/bin/bash

#
# Adapted from Ref:
#   https://aws.amazon.com/blogs/containers/maintaining-transport-layer-security-all-the-way-to-your-container-using-the-application-load-balancer-with-amazon-ecs-and-envoy/
#

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $scriptDir

#EC2
create_acm_certificate=false
create_and_setup_alb=false
create_and_setup_asg=false
export certificateArn=arn:aws:acm:eu-west-1:489880714178:certificate/cc022604-de71-4cc6-b207-ab58c17b918e
export loadbalancerArn=arn:aws:elasticloadbalancing:eu-west-1:489880714178:loadbalancer/app/ecs-repo-board-alb/fb451339369866e3
export targetGroupArn=arn:aws:elasticloadbalancing:eu-west-1:489880714178:targetgroup/ecs-repo-board-https-target/c97c4aacc283d32d

#ECS
create_ecr_repo=false
docker_push_proxy=false
docker_push_test_app=false
create_ecs_cluster_and_task=false
create_ecs_service=true


#--------------------------------------------------------#
###--------Define necessary environment variables-----##
##------------------------------------------------------#
source variables.sh #many key variables returned


#--------------------------------------------------------#
##------- Create two ECR repositories to store
#-------- the application and Envoy container images.
##------------------------------------------------------#


if $create_ecr_repo ; then
    source create_ecr_repos.sh #no variables returned
fi

#--------------------------------------------------------#
###-------- Create an Envoy configuration file. -----##
###-------- Create and push docker images ----------##
##------------------------------------------------------#

if $docker_push_proxy || $docker_push_test_app; then
    ## Login to ECR
    aws ecr get-login-password --region $region --profile ${profile_name} \
        | docker login \
                 --username AWS \
                 --password-stdin https://${account}.dkr.ecr.${region}.amazonaws.com
fi

if $docker_push_proxy; then    
    #create envoy config and docker image
    source create_proxy_envoy.sh #no variable returned
    docker push ${aws_ecr_repository_url_proxy}
fi

echo "current dir: `pwd`"
if $docker_push_test_app; then
    #create test app
    source test_app_docker.sh  #no variable returned
    docker push ${aws_ecr_repository_url_app}
fi

#--------------------------------------------------------#
###-------- Create cluster and task definition -----##
##------------------------------------------------------#
echo "current dir: `pwd`"
if $create_ecs_cluster_and_task; then
    #no variables returned
    source create_ecs_cluster.sh 
fi

#--------------------------------------------------------#
###************** returns needed variables *************#
###-------- Certificate setup -----##
##------------------------------------------------------#

if $create_acm_certificate && [ -z $certificateArn ]; then
    echo "Getting ACM certificate ..."
    source acm_certificate_setup.sh  #returns needed variables
fi

#stop if variable is not set
if [ -z $certificateArn ]; then
    echo "certificateArn is not set"
    exit 0
fi
#--------------------------------------------------------#
###-------- Create the Application Load Balancer -----##
##------------------------------------------------------#

if $create_and_setup_alb; then
    if [ -z $loadbalancerArn ] || [ -z $targetGroupArn ]; then
        echo "Creating and setting up ALB  ..."        
        source create_alb.sh #returns needed variables
    fi
fi

#stop if variables are not set
if [ -z $loadbalancerArn ] || [ -z $targetGroupArn ]; then
    exit 0    
fi

#--------------------------------------------------------#
###-------- Create the Application Auto Scaling Group -----##
##------------------------------------------------------#

if $create_and_setup_asg && [ $ECSLaunchType == "EC2" ]; then
    echo "Creating and setting up ASG  ..."        
    source create_asg.sh #no variable returned
fi

#--------------------------------------------------------#
###-------- Certificate setup -----##
##------------------------------------------------------#

if $create_ecs_service; then
    echo "Creating ECS service .."
    source create_ecs_service.sh 
fi

#--------------------------------------------------------#
###-------- Certificate setup -----##
##------------------------------------------------------#

#echo quit | openssl s_client -showcerts -servername ecs-encryption.awsblogs.info -connect ecs-encryption.awsblogs.info:443 > cacert.pem

##Hit the service 
#curl --cacert cacert.pem https://ecs-encryption.awsblogs.info/service

