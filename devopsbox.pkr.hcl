
variable "version" {
    type = string
    default = "0.1.1"
    description = "Version of the image"
}

variable "architecture" {
    type = string
    default = "amd64"
    description = "Architecture of the image"
}

locals {
    packer_version = "1.10.1"
    packer_architecture = var.architecture
    packer_url = "https://releases.hashicorp.com/packer/${var.packer_version}/packer_${var.packer_version}_linux_${var.packer_architecture}.zip"
}

source "docker" "devopsbox" {
    image = "ubuntu:latest"
    export_path = "image.tar"
    changes = [
        "USER devops",
        "VOLUME /workdir"
    ]
}

build {
    sources = ["source.docker.devopsbox"]

    provisioner "shell" {
        inline = [
            "apt update",
            "apt install -y curl unzip",
            "mkdir -p /workdir",
            "mkdir -p /devops/tools",
        ]
    }

    # docker
    provisioner "shell" {
        inline = [
            "curl -fsSL https://get.docker.com -o /devops/tools/get-docker.sh",
            "sh /devops/tools/get-docker.sh"
        ]
    }

    #packer
    provisioner "shell" {
        inline = [
            "curl -fsSL ${local.packer_url} -o /devops/tools/packer.zip",
            "unzip /devops/tools/packer.zip -d /devops/tools",
        ]
    }

    #kubectl
    provisioner "shell" {
        inline = [
            "curl -fsSL https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl -o /devops/tools/kubectl",
            "chmod +x /devops/tools/kubectl",
        ]
    }

    post-processors {
        post-processor "docker-import" {
            repository = "vinik/devopsbox"
            tag = var.version
        }
        post-processor "docker-push" {}
        post-processor "docker-tag" {
            repository = "vinik/devopsbox"
            tag = ["latest"]
        }
        post-processor "docker-push" {}
    }
}

