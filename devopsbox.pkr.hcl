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
            "curl -fsSL https://releases.hashicorp.com/packer/1.8.0/packer_1.8.0_linux_amd64.zip -o /devops/tools/packer.zip",
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
            tag = "0.1.0"
        }
        post-processor "docker-push" {}
        post-processor "docker-tag" {
            repository = "vinik/devopsbox"
            tag = ["latest"]
        }
        post-processor "docker-push" {}
    }
}

