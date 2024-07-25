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

variable "version" {
  type = string
  default = "0.1.0"

}

# DOCKER
variable "docker_hub_username" {
  type = string
  default = "-- Your docker hub username --"
}

variable "docker_hub_password" {
  type = string
  default = "-- Your docker hub password --"
}

# GCP
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

source "googlecompute" "google" {
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

source "docker" "container" {
    image = "ubuntu:24.04"
    export_path = "image.tar"
    changes = [
        "VOLUME /workdir"
    ]
}

build {
    name = "base"

    sources = [
        "source.googlecompute.google",
        "source.docker.container"
    ]
    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get upgrade -y"
        ]
        override = {
          container = {
            inline = [
              "apt-get update",
              "apt-get upgrade -y"
            ]
          }
        }
    }
    

    post-processors  {      
        post-processor "docker-import" {
            repository = "vinik/base"
            tag = var.version
            only = [ "docker.container" ]
        }
        post-processor "docker-push" {
            login = true
            login_username = var.docker_hub_username
            login_password = var.docker_hub_password
            only = [ "docker.container" ]
        }
        post-processor "docker-tag" {
            repository = "vinik/base"
            tag = ["latest"]
            only = [ "docker.container" ]
        }
        post-processor "docker-push" {
            login = true
            login_username = var.docker_hub_username
            login_password = var.docker_hub_password
            only = [ "docker.container" ]
        }
    }

    
}