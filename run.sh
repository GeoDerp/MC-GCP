#!/bin/bash
#This file runs on startup in the VM. It installs scripts used to check container status and shutdown if the container has stopped

#create directory if havent yet 
mkdir -p /home/data/mc 

#container check health script 
echo '#!/bin/bash' >> /home/data/containerHealth.sh 
echo "containerV=\$(docker ps -a | grep 'itzg/minecraft-server' | cut -d ' ' -f1|tr '\n' ' '); if [ \$(docker inspect -f '{{.State.Running}}' \$containerV) = 'true' ]; then echo up; else sudo init 6; fi;" >> /home/data/containerHealth.sh 
chmod +x /home/data/containerHealth.sh 

#create timer to check run helth service every 5min
cat <<END > /etc/systemd/system/containerTimer.timer
[Unit]
Description=Timer that runs containerHealthRunner.service

[Timer]
Unit=containerService.service
OnBootSec=5min
OnCalendar=*:0/5
Persistent=True

[Install]
WantedBy=multi-user.target
END

#create service to run health script
cat <<EOF > /etc/systemd/system/containerService.service
[Unit]
Description="Runs Script to check Minecraft Container Health"

[Service]
ExecStart=/home/data/containerHealth.sh 
EOF

#enable timer
sudo systemctl enable containerTimer.timer


