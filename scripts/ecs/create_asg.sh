
####### Reference
### https://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html
######

aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name $AsgName \
    --launch-template LaunchTemplateName=$AsgTemplateName,Version='$Latest' \
    --target-group-arns $targetGroupArn \
    --health-check-type ELB \
    --health-check-grace-period 600 \
    --min-size $AsgMaxSize \
    --max-size $AsgMaxSize \
    --desired-capacity $AsgDesiredSize \
    --termination-policies "OldestInstance" \
    --vpc-zone-identifier "$public_subnet1,$public_subnet2,$private_subnet1,$private_subnet2" \
    --region $region --profile ${profile_name}
#    --tags "ResourceId=my-asg,ResourceType=auto-scaling-group,Key=Role,Value=DockerMicroInstance,PropagateAtLaunch=true" \
