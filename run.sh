#!/bin/bash
#This file runs on startup in the VM. It installs scripts used to check container status and shutdown if the container has stopped

#create directory if havent yet 
mkdir -p /home/data/mc 

#container check health script 
if [ \$(docker inspect -f '{{.State.Running}}' \$containerV) = 'true' ]; 
then
sudo rm -f /home/data/containerHealth.sh
cat <<END > /home/data/containerHealth.sh 
#!/bin/bash
containerV=\$(docker ps -a | grep 'itzg/minecraft-server' | cut -d ' ' -f1|tr '\n' ' ')
if [ \$(docker inspect -f '{{.State.Running}}' \$containerV) = 'true' ]; then echo up; else sudo systemctl disable containerTimer.timer && sudo poweroff; fi;
END
chmod +x /home/data/containerHealth.sh 

#create timer to check run helth service every 5min
sudo rm -f /etc/systemd/system/containerTimer.timer && cat <<END > /etc/systemd/system/containerTimer.timer
[Unit]
Description=Timer that runs containerHealthRunner.service
After=docker.service

[Timer]
Unit=containerService.service
OnBootSec=5min
OnCalendar=*:0/5
Persistent=True

[Install]
WantedBy=multi-user.target
END

#create service to run health script
sudo rm -f /etc/systemd/system/containerService.service && cat <<EOF > /etc/systemd/system/containerService.service
[Unit]
Description="Runs Script to check Minecraft Container Health"
After=docker.service

[Service]
ExecStart=bash /home/data/containerHealth.sh 
EOF

#enable timer
sudo systemctl enable containerTimer.timer
sudo systemctl start containerTimer.timer

# if script could not find container
else echo "could not find container"
fi
