source "docker" "devopsbox" {
    image = "ubuntu:latest"
    export_path = "image.tar"
}

build {
    sources = ["source.docker.devopsbox"]

    provisioner "shell" {
        inline = [
            "echo 'Hello World' > /root/hello.txt"
        ]
    }

    post-processors {
        post-processor "docker-import" {
            repository = "vinik/devopsbox"
            tag = "0.1.0"
        }
        post-processor "docker-tag" {
            repository = "vinik/devopsbox"
            tag = ["latest"]
        }
        post-processor "docker-push" {}
    }
}

