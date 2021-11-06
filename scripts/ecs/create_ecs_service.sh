#--------------------------------------------------------#
###-------- Certificate setup -----##
##------------------------------------------------------#
mkdir -p output/ecs

#Create the service
#Create the ECS service definition template. Replace the values in the file to match your account.
if [ "$ECSLaunchType" == "EC2" ]; then
cat <<EOF >  ecs_service_def.template
{
    "serviceName": "${service_name}",
    "cluster": "arn:aws:ecs:$region:$account:cluster/$cluster",
    "taskDefinition": "arn:aws:ecs:$region:$account:task-definition/$task_name",
    "loadBalancers": [
                {
                    "targetGroupArn": "$targetGroupArn",
                    "containerName": "${proxy_container_name}",
                    "containerPort": 443
                }
            ],
    "launchType": "$ECSLaunchType", 
    "deploymentConfiguration": {
                "maximumPercent": 200,
                "minimumHealthyPercent": 0
            },
    "desiredCount": 1,
    "healthCheckGracePeriodSeconds": 0,
    "schedulingStrategy": "REPLICA",
    "enableECSManagedTags": false,
    "propagateTags": "TASK_DEFINITION"    
}
EOF
else
cat <<EOF >  ecs_service_def.template
{
    "serviceName": "${service_name}",
    "cluster": "arn:aws:ecs:$region:$account:cluster/$cluster",
    "taskDefinition": "arn:aws:ecs:$region:$account:task-definition/$task_name",
    "loadBalancers": [
                {
                    "targetGroupArn": "$targetGroupArn",
                    "containerName": "${proxy_container_name}",
                    "containerPort": 443
                }
            ],
    "launchType": "$ECSLaunchType", 
    "platformVersion": "LATEST",
    "networkConfiguration": {
                "awsvpcConfiguration": {
                    "subnets": [
                        "$private_subnet1", "$private_subnet2"
                    ],
                    "securityGroups": [
                        "$sg"
                    ],
                    "assignPublicIp": "ENABLED"
                }
            },
    "deploymentConfiguration": {
                "maximumPercent": 200,
                "minimumHealthyPercent": 0
            },
    "desiredCount": 1,
    "healthCheckGracePeriodSeconds": 0,
    "schedulingStrategy": "REPLICA",
    "enableECSManagedTags": false,
    "propagateTags": "TASK_DEFINITION"    
}
EOF
fi    
#And create the ECS Service, using the registered task definition and the Application Load Balancer.
envsubst <ecs_service_def.template>ecs_service_def.json

##create service 
aws ecs create-service --cluster $cluster \
    --service-name ${service_name} \
    --cli-input-json file://ecs_service_def.json \
    --region $region --profile ${profile_name}

mv ecs_service_def.* output/ecs

# aws ecs create-capacity-provider \
#     --name "${service_name}_cp" \
#     --auto-scaling-group-provider autoScalingGroupArn=arn:aws:autoscaling:us-west-2:123456789012:autoScalingGroup:a1b2c3d4-5678-90ab-cdef-EXAMPLE11111:autoScalingGroupName/MyAutoScalingGroup,managedScaling={status=ENABLED,targetCapacity=100,minimumScalingStepSize=1,maximumScalingStepSize=100},managedTerminationProtection=ENABLED
