email_id = "*-compute@developer.gserviceaccount.com"
region_id = ""
zone_id = ""
country = ""
container_VM_id = "cos-stable-105-17412-101-24"
ops = ""
project_id = ""
machine_type = "e2-standard-2"
java_memory = "6G"
on_host_maintenance = "MIGRATE"
provisioning_model = "STANDARD"
EULA = "FALSE"
container_extraENVs = "value: MODRINTH\n    - name: MODRINTH_PROJECT\n      value: O8OAvFdJ\n    - name: MODRINTH_PROJECTS\n      value: 8oi3bsk5,D53qveoj,Ys1mdL6V,4im8hCxA\n"
google-logging-enabled = "true"
network_tier = "PREMIUM"
boot_disk_storage = 10


//KEEP DEFAULTS BELLOW TO ENABLE AUTOSTOP FUNCTION
container_autostop = "true"
vm_automatic_restart = "false"
vm_startupscript =  "git clone https://github.com/GeoDerp/MC-GCP && cd MC-GCP && sleep 5 && chmod +x run.sh && sudo bash ./run.sh"
restartPolicy = "Never"
preemptible = "true"
persistent_disk_id = "pd-balanced"