# This Terraform template was autogenerated by Google Cload Platform, then modified to tweak parameters 
# it is recommended to make a new VPC network (and change from defult) if you use this GCP project for more then just the Minecraft Server (for security)
# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration


//VARIBLES

variable "email_id" {
  description = "service account email (find it at APIs & Services > Credentials > Compute Engine default service account )"
  default = ""
}

variable "region_id" {
  description = "region id for location to run resource https://cloud.google.com/compute/docs/regions-zones#available"
  default = ""
}

variable "zone_id" {
  description = "zone id for isolated location in region where your VM will be run https://cloud.google.com/compute/docs/regions-zones#available"
  default = ""
}

variable "country" {
  description = "country you would like the cloud funtion to run ex. AU"
  default = ""
}  

variable "container_VM_id" {
  description = "container-optimised os id https://cloud.google.com/feeds/cos-105-release-notes.xml"
  default = "cos-stable-105-17412-101-24"
}

variable "ops" {
  description = "comma separated string of minecraft usernames to op"
  default = ""
}

variable "project_id" {
  description = "project id of the project you wish the VM to run in (gcloud config get-value project)"
  default = ""

}

variable "machine_type" {
  description = "id of the machine configuration you would like to use https://cloud.google.com/compute/all-pricing"
  default = "e2-standard-2"
}

variable "java_memory" {
  description = "recommended to set memory to 75% of VM total"
  default = "6G"
}


variable "on_host_maintenance" {
  default = "MIGRATE"
  description = "set to 'TERMINATE' to significantly decrease cost but increase likelihood of random server stops"
}

variable "provisioning_model" {
  default = "STANDARD"
  description = "set to 'SPOT' to significantly decrease cost but increase likelihood of random server stops"
}

variable "EULA" {
  description = "Setting it to true, you will accept the Mojang/Microsof EULA https://www.minecraft.net/en-us/eula (required to set to 'TRUE' to run)"
  default = "FALSE"
}

variable "container_extraENVs" {
  description = "for extra adding environment variables into the minecraft container https://docker-minecraft-server.readthedocs.io "
  default = "value: MODRINTH\n    - name: MODRINTH_PROJECT\n      value: O8OAvFdJ\n    - name: MODRINTH_PROJECTS\n      value: 8oi3bsk5,D53qveoj,Ys1mdL6V,4im8hCxA\n"
}

variable "google-logging-enabled" {
  description = "enable google logging"
  default = "true"
}


variable "boot_disk_storage" {
  description = "amount of gb on disk"
  default = 10
}


variable "network_tier" {
  default = "PREMIUM"
}


//KEEP DEFAULTS BELLOW TO ENABLE AUTOSTOP FUNCTION
variable "container_autostop" {
  description = "to enable container to stop when no players are active https://docker-minecraft-server.readthedocs.io/en/latest/misc/autopause-autostop/autostop/"
  default = "true"
}

variable "vm_automatic_restart" {
  description = "to automatically restart VM if 'terminated for non-user-initiated reasons'"
  default = "false"
}

variable "vm_startupscript" {
  description = "startup script for vm"
  default = "sudo mkdir -p /home/data && sudo chmod -R u=rwx /home/data && cd /home/data && git clone https://github.com/GeoDerp/MC-GCP && cd MC-GCP && sleep 5 && chmod +x run.sh && sudo bash ./run.sh"
}

variable "restartPolicy" {
  description = "set to always for container restart on crash"
  default = "Never"
}

variable "preemptible" {
  default = "false"
}

variable "persistent_disk_id" {
  description = "select type of persistent disk pd-standard,pd-balanced,pd-ssd,pd-extreme https://cloud.google.com/compute/docs/disks"
  default = "pd-balanced"
}



//RESOURCES

//VM,IP and FIREWALL
# create GCP VM
resource "google_compute_instance" "my-mc-server" {
      
  boot_disk {
    auto_delete = false
    device_name = "my-mc-server"

    initialize_params {
      image = "projects/cos-cloud/global/images/${var.container_VM_id}"
      size  = var.boot_disk_storage
      type  = var.persistent_disk_id
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    container-vm = var.container_VM_id
    goog-ec-src  = "vm_add-tf"
  }

  machine_type = var.machine_type

  metadata = {
    gce-container-declaration = "spec:\n  containers:\n  - name: my-mc-server\n    image: docker.io/itzg/minecraft-server\n    env:\n    - name: EULA\n      value: ${var.EULA}\n    - name: ENABLE_AUTOSTOP\n      value: ${var.container_autostop}\n    - name: MEMORY\n      value: ${var.java_memory}\n    - name: OPS\n      value: ${var.ops}\n    - name: TYPE\n      ${var.container_extraENVs}    volumeMounts:\n    - name: host-path-0\n      readOnly: false\n      mountPath: /data\n    securityContext:\n      privileged: true\n    stdin: true\n    tty: true\n  volumes:\n  - name: host-path-0\n    hostPath:\n      path: /home/data/mc\n  restartPolicy: ${var.restartPolicy}\n"
    google-logging-enabled    = var.google-logging-enabled
    startup-script            = var.vm_startupscript
  }

  name = "my-mc-server"

  network_interface {
    network = "default"
    access_config {
      network_tier = var.network_tier 
      nat_ip = google_compute_address.default.address
    }

    subnetwork = "projects/${var.project_id}/regions/${var.region_id}/subnetworks/default"
  }

  scheduling {
    automatic_restart   = var.vm_automatic_restart
    on_host_maintenance = var.on_host_maintenance
    preemptible         = var.preemptible
    provisioning_model  = var.provisioning_model
  }

  service_account {
    email  = var.email_id
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = var.zone_id
  project = var.project_id
}

#set static ip
resource "google_compute_address" "default" {
  name   = "my-static-mc-ip"
  region = var.region_id
  project = var.project_id
}

#create firewall rules 
resource "google_compute_firewall" "rules" {
  name        = "tcp-mc-server-port-rule"
  network     = "default"
  description = "opens mc server port tcp"
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["25565", "25565"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# create udp firewall rules (optional)
# resource "google_compute_firewall" "rules" {
#   name        = "udp-mc-server-port-rule"
#   network     = "default"
#   description = "opens mc server port udp"
#   project = var.project_id

#   allow {
#     protocol = "udp"
#     ports    = ["25565", "25565"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }
