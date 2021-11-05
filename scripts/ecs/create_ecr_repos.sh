#--------------------------------------------------------#
##------- Create two ECR repositories to store
#-------- the application and Envoy container images.
##------------------------------------------------------#

echo "service_name=${service_name}; app_name=${app_name}; region=$region"
#Repository 1:
aws ecr create-repository \
    --repository-name ${app_name} \
    --region $region --profile ${profile_name}


#Repository 2:
aws ecr create-repository --repository-name ${proxy_name} \
    --region $region --profile ${profile_name}
