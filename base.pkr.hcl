packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}


variable "gcp_project_id" {
  type = string
  default = ""
}

variable "gcp_credentials_json" {
  type = string
  default = ""

}

variable "my_prefix" {
  type = string
  default = ""
}

locals {
  gcp_machine_type = "e2-micro"
  gcp_region = "us-central1"
  gcp_zone = "us-central1-a"
  gcp_image_name = "${var.my_prefix}-base-{{timestamp}}"
}

source "googlecompute" "base" {
    project_id = var.gcp_project_id
    source_image_family = "ubuntu-2404-lts-amd64"
    zone = local.gcp_zone
    ssh_username = "packer"
    credentials_json  = var.gcp_credentials_json
    image_name = local.gcp_image_name
    image_description = "Base Image"
    image_family = var.my_prefix
    disk_size = 10
    machine_type = local.gcp_machine_type   
}

source "docker" "base" {
    image = "ubuntu:24.04"
    export_path = "image.tar"
    changes = [
        "VOLUME /workdir"
    ]
}

build {
    name = "base"

    sources = [
        "source.googlecompute.base",
        "source.docker.base"
    ]
    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y"
        ]
        only = [ "source.googlecompute.base" ]
    }
    provisioner "shell" {
        inline = [
            "apt-get update",
            "apt-get upgrade -y"
        ]
        only = [ "source.docker.base" ]
    }

    post-processors  {      
        post-processor "docker-import" {
            repository = "vinik/base"
            tag = var.version
            only = [ "source.docker.base" ]
        }
        post-processor "docker-push" {
            only = [ "source.docker.base" ]
        }
        post-processor "docker-tag" {
            repository = "vinik/base"
            tag = ["latest"]
            only = [ "source.docker.base" ]
        }
        post-processor "docker-push" {}
    }

    
}