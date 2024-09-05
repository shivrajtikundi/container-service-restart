
###############

:

*

#!/bin/bash

# Start Milvus Standalone
/usr/bin/docker start -a milvus-standalone &

# Start Milvus Minio
/usr/bin/docker start -a milvus-minio &

# Start Milvus Etcd
/usr/bin/docker start -a milvus-etcd &

*

sudo chmod +x /usr/local/bin/start-containers.sh

*
/usr/local/bin/stop-containers.sh:

*

#!/bin/bash

# Stop Milvus Standalone
/usr/bin/docker stop -t 2 milvus-standalone

# Stop Milvus Minio
/usr/bin/docker stop -t 2 milvus-minio

# Stop Milvus Etcd
/usr/bin/docker stop -t 2 milvus-etcd

*

sudo chmod +x /usr/local/bin/stop-containers.sh

*

/etc/systemd/system/containers.service:

[Unit]
Description=Milvus Containers
After=docker.service    #if installed by snap use this docker.dockerd not docker.service
Requires=docker.service

[Service]
Environment="PATH=/usr/bin:/usr/local/bin"
Restart=always
ExecStart=/usr/local/bin/start-containers.sh
ExecStop=/usr/local/bin/stop-containers.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target


######

sudo systemctl daemon-reload
sudo systemctl enable containers.service
sudo systemctl start containers.service
###

sudo systemctl status containers.service

######
 install cloudwatch agent 
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

################################################################################new code




vim /usr/local/bin/start-containers.sh



#!/bin/bash

# Function to start container if it is not running
# SNS Topic ARN
SNS_TOPIC_ARN="arn:aws:sns:eu-central-1:338812281461:DockerContainerAlerts"
LOG_FILE="/var/log/docker-monitor.log"
start_container() {
    local container_name=$1
    if [ "$(docker inspect -f '{{.State.Running}}' $container_name)" == "false" ]; then
       echo "Starting $container_name..."
       /usr/bin/docker start $container_name
       # Send SNS notification
       aws sns publish --topic-arn "$SNS_TOPIC_ARN" --subject "Docker Container Alert" --message "Container $container_name was stopped and has been restarted." | tee -a $LOG_FILE
     fi
 }
 # Initial start of containers
 /usr/bin/docker start milvus-standalone
 /usr/bin/docker start milvus-minio
 /usr/bin/docker start milvus-etcd
 # Monitor and restart stopped containers
 while true; do
     start_container "milvus-standalone"
     start_container "milvus-minio"
     start_container "milvus-etcd"
     sleep 60  # Check every 60 seconds
 done



#stop script is same abovvee
#containers.service:   it will also be same


#
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ubuntu/cloudwatch-agent-config.json -s




