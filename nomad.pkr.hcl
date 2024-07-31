packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "gcp_project_id" {
    type = string
}

variable "gcp_credentials_json" {
    type = string
}

variable "my_prefix" {
    type = string
}

locals {
    gcp_machine_type = "e2-micro"
    gcp_region = "us-central1"
    gcp_zone = "us-central1-a"
    gcp_image_name = "${var.my_prefix}-nomad-{{timestamp}}"
    gcp_base_image_family = "${var.my_prefix}-base"
}

source "googlecompute" "google" {
    project_id = var.gcp_project_id
    source_image_family = local.gcp_base_image_family
    zone = local.gcp_zone
    ssh_username = "packer"
    credentials_json  = var.gcp_credentials_json
    image_name = local.gcp_image_name
    image_description = "Nomad Image"
    image_family = var.my_prefix
    disk_size = 10
    machine_type = local.gcp_machine_type   
}


build {
    sources = [
        "sources.googlecompute.google"
    ]

    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y",
            "sudo mkdir -p /workdir",
            "sudo mkdir -p /devops/tools",
        ]
        environment_vars = [
            "DEBIAN_FRONTEND=noninteractive"
        ]
    }

    provisioner "shell" {
        inline = [
            "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
            "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
            "sudo apt update",
            "sudo apt install -y nomad"
        ]
        environment_vars = [
            "DEBIAN_FRONTEND=noninteractive"
        ]
    }

    # docker
    provisioner "shell" {
        inline = [
            "sudo curl -fsSL https://get.docker.com -o /devops/tools/get-docker.sh",
            "sudo sh /devops/tools/get-docker.sh"
        ]
        environment_vars = [
            "DEBIAN_FRONTEND=noninteractive"
        ]
    }

}