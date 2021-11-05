if [ $# -gt 0 ]; then
    action=$1
else
    action="status"
fi

echo "Requested action is: $action"

TYPE="g4dn.2xlarge"   # EC2 instance type
team="b4trainees"
region="eu-west-1"

#####example to start at 6hr utc and stop at 21hr utc
#0 6 * * * /bin/bash /home/centos/trainees_aws_cluster/start_stop.sh start > /home/centos/cronlog.txt
#0 21 * * * /bin/bash /home/centos/trainees_aws_cluster/start_stop.sh stop > /home/centos/cronlog.txt 

echo "------------------------------------"
echo "                 `date`"
echo "------------------------------------"
echo ""


# InstanceIds=$(aws ec2 describe-instances \
#                   --filters "Name=instance-type,Values=$TYPE" \
#                   --filters "Name=tag:team,Values=$team" \
#                   --query "Reservations[].Instances[].InstanceId")

RequestedFields="{Id:InstanceId,PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}"
InstanceVars=$(aws ec2 describe-instances --region $region \
                   --filters "Name=instance-type,Values=$TYPE" \
                   --filters "Name=tag:team,Values=$team" "Name=tag:Name,Values='b4_group_*'" \
                   --query "Reservations[*].Instances[*].$RequestedFields" \
            )

# get length of an array
arrayId=( `echo $InstanceVars | jq -re '.[] | .[] | .Id'` )
arrayState=( `echo $InstanceVars | jq -re '.[] | .[] | .Status'` ) 


# use for loop to read all values and indexes
arraylength=${#arrayId[@]}
for (( i=0; i<${arraylength}; i++ ));
do
    id=${arrayId[$i]}
    state=${arrayState[$i]}
    echo "InstanceId = $id has InstanceState = $state"
    
    if [ $action = "start" ]; then
        if [ $state = "stopped" ]; then
            echo "starting instance-id=$id .."
            aws ec2 start-instances --region $region --instance-ids $id
        fi
    fi
    if [ $action = "stop" ]; then
        if [ $state = "running" ]; then
            echo "stopping instance-id=$id .."
            aws ec2 stop-instances --region $region --instance-ids $id
        fi
    fi
    
done
