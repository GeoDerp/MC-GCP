# MC-GCP
Minecraft server running GCP (Google Cloud Platform) container optimized OS VM. </br>
Included is an auto run script that auto stops the VM (reducing VM costing) when the container has shut down from a period of player inactivity (default: 30m).
You can then use the cloud start function provided to start the server up again with a generated url link. 


## Included Files 

### GCPContainer.tf
---
This is the Terraform file use to generate the GCP VM, firewall, static IP.  
*note: VM, storage and static IP will likley be billable when run*

For information on how to use Terraform, have a look at:
- Google's blog here: https://cloud.google.com/docs/terraform/get-started-with-terraform
- Terraforms blog here: https://developer.hashicorp.com/terraform/tutorials/kubernetes/gke

- the generated GCP VM uses [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server) container to run the minecraft server. `docker-minecraft-server` is very powerful, I recommend looking at the environment variable's that are set up in the Terraform .tf file, plus, [itzg's documentation](https://docker-minecraft-server.readthedocs.io/en/latest/)
to understand what is happening, to make your own changes.

- by default, the container runs an instance of the Modrinth modpack I have have created called: [GeoAndFriends](https://modrinth.com/modpack/geoandfriends), however, feel free to change this as you please.

### How to install VM, fireall and Static IP using Terraform
*make sure you have terraform, Google Cloud SDK and have cloned the repo before starting*
```bash
#clone git repo
cd MC-GCP
nano terraform.tfvars #edit terraform.tfvars, replace values for variables applicable
gcloud init #if you haven't already
gcloud auth application-default login #if you haven't already
terraform.exe init
terraform.exe plan #check if your happy with the output
terraform.exe apply #type yes
```
 
### ./startCloadFunction & ./stopCloadFunction
---
*The following components will be could be billable using cloud functions:*
    - *Cloud Functions*
    - *Cloud Build*
    - *Cloud Storage*
    - *Artifact Registry*

*possible to-do: make cloud functions apart of the Terraform template as well*  

Included are some Node.js files used for Googles "Cloud Function". These scripts use Google's gen2 Cloud Function Environment to allow you to start and stop the server with a url trigger. 

Currently the GCP VM is (or should be) setup in a way to auto stop when there is no active players. This works nicely with the start cloud function, to allow users to click a url to start the server, play on the server for a time, leave the server and have the server auto stop on a period of inactivity (30m by default) to reduce GCP costs. (change the inactivity times via the [container environment variables](https://docker-minecraft-server.readthedocs.io/en/latest/misc/autopause-autostop/autostop/) *add extra variables in the `container_extraENVs` section of `terraform.tfvars`. Make sure you have the spacing correct*)

### Instructions to add Cloud Functions (MANUAL)

To add these scripts:
- modify the `MYPROJECTID` and `ZONE` in the file/s to fit your project ID 
- click "create a new Cloud" function
- make sure the environment is set to `2nd gen`
- set region
- set "allow unauthenticated invocations" in the authentication section (if you would like anyone to be able to start/stop the url with the link)
- click next, paste in the code from the following function folder *(ie: /startCloudFunction*)  
- set `Entry point` to either "startInstancehttp" or "stopInstancehttp" *(depending on the function)*
- click deploy. You should be good to use the url generated to start/stop the GCP VM

**Note:** when running the function, because of how it's currently set up, the url link will give an html error when run. This is normal and the function will still operate in the background. The Google Cloud Function/s could also cost some money.

### run.sh
---
Script used on GCP VM on startup to create system services and script to routinely check container health/status. If the container has stopped, the script will run a shutdown command on the VM. This is used for auto shutting down VM on container crash or when autostop is enabled on the container to turn off after a period of minecraft player inactivity (set up by default on the .tf). Autostop has been stup using itzg's [AUTOSTOP feature](https://docker-minecraft-server.readthedocs.io/en/latest/misc/autopause-autostop/autostop/)

*This is designed to reduce costs. But feel free to remove this script via the `startup` at `terraform.tfvars` to stop run.sh from running. If you do this I also recommend setting ` restartPolicy=Always` `vm_automatic_restart=true` and `container_autostop=false` from the  container environment variables in the .tfvars .*

**Files Generated:**
- /home/data/containerHealth.sh - used to check docker container health
- /etc/systemd/system/containerTimer.timer - used to set 5m increments to run .service
- /etc/systemd/system/containerService.service - used with .timer to run .sh command every 5min

### Extra Notes 
---
- this project is very much in development, so fell free to make an issue or create a pull request for any fixes/improvements to the corresponding code
- when you stop the VM, you will still generate some costs, the main one being the cost for persistent disk.
- The .tf file has the minecraft container memory to 6GB, and the VM memory to 8GB (e2-standard-2 being 2vCPUs and 8gb of Memory). feel free to change this but I recommend sticking to the container being 75% of the overall VM memeory.
- provisioning model is set to "STANDARD". Setting it to "SPOT" will significantly decrease cost, however will increase likelihood of random server stops as your sharing resources with other Google Services
- I recommend using the `scp` command to backup your world before doing any major changes. Your world should be stored in `/home/data/mc` on the boot disk. Regular backups is also recommended. (ex. ```rsync -vPah USERNAME@IPADDRESS:/home/data/mc ~/mcbackup/```)
