#--------------------------------------------------------#
###--------Define necessary environment variables-----##
##------------------------------------------------------#
#aws cli profile 
export profile_name="adludio"
export email="yabebal.tadesse@adludio.com"
echo "profile=$profile_name"

#application and proxy names
export root_name="repo-board"
export app_name="${root_name}"  #-app
export proxy_name="${root_name}-proxy"
export log_group_name="/ecs/ecs-${root_name}-ssl"
export dns_namespace="ditapi.futureadlabs.com"  ##This should be your domain
export repo_name="api.repo-board.com"
echo "root_name=$root_name"


#ECS parameters
export app_container_name="${root_name}-container"  #-app
export proxy_container_name="${root_name}-proxy-container"
export task_name="ecs-${root_name}-task"
export service_name="ecs-${root_name}-service"
export cluster="ecs-${root_name}-cluster"
export ECSLaunchType="EC2"
#"FARGATE"

#loadbalance and autoscale
export alb="ecs-${root_name}-alb"
export AsgName="ecs-${root_name}-asg"
export AsgMinSize=1
export AsgMaxSize=1
export AsgDesiredSize=1
export AsgTemplateId="lt-0a4480956309cfdad"
export AsgTemplateName="EC2ContainerService-EcsOptAMI2-t3med"
export AsgTemplateVersion=2


##Export region and account
export AccountId=$(aws sts get-caller-identity --query Account --output text --profile ${profile_name})  
export AWS_REGION=${ADLUDIO_AWS_REGION:-"eu-west-1"} # <- Your AWS Region
export account=$AccountId
export region=$AWS_REGION
echo "account=$account"
echo "region=$region"

##Export key networking constructs
#Subsitute these values with your VPC subnet ids
export private_subnet1="subnet-df5a8197" #private-data-subnet-a 
export private_subnet2="subnet-f8e1f6a3" #private-data-subnet-b 
export public_subnet1="subnet-ff24ffb7" #public-data-subnet-a
export public_subnet2="subnet-92e0f7c9" #public-data-subnet-b
export sg="sg-152edb69"   ##open access SG for ALB ssh/http/https All 0.0.0.0/0
export vpcId="vpc-92fd7af4" # (data-vpc) <- Change this to your VPC id
echo "vpcid=$vpcId"

##Service name and domain to be used
export aws_ecr_repository_url_app=$account.dkr.ecr.$region.amazonaws.com/${app_name}
export aws_ecr_repository_url_proxy=$account.dkr.ecr.$region.amazonaws.com/${proxy_name}
echo "dns=$dns_namespace"
echo "ecs cluster=$cluster"


#ECS task execution IAM role
export ecsTaskExecutionRoleArn="arn:aws:iam::$account:role/ecsTaskExecutionRole"

if [ -f template/circleci.template ]; then
    envsubst <template/circleci.template>template/config.yml
    echo "template/circleci.template variables replaced and saved as template/config.yml"
    echo "------------ circleci header -------------"
    head -n28 template/config.yml | tail -n+6
    echo "-----------------------------------------"
fi
