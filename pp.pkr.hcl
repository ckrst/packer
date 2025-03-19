packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

variable "version" {
    type = string
    default = "0.1.0"
    description = "Version of the image"
}

source "docker" "pp" {
    image = "vinik/base:0.1.0"
    export_path = "image.tar"
    changes = [
        "USER devops",
        "VOLUME /workdir"
    ]
}

build {
    sources = ["source.docker.pp"]

    provisioner "shell" {
        inline = [
            "apt update",
            "apt install -y curl unzip wget apt-utils software-properties-common git",
            "mkdir -p /workdir",
            "mkdir -p /devops/tools",
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }

    }

    # apache
    provisioner "shell" {
        inline = [
            "apt install -y apache2"
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }
    }

    # php 5.6
    provisioner "shell" {
        inline = [
            "apt-add-repository ppa:ondrej/php",
            "apt install -y php5.6",
            "php -v",
            # "update-alternatives --config php",
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }

    }

    # tzdata
    provisioner "shell" {
        inline = [
            "ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime",
            "DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata",
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
            TZ = "America/Sao_Paulo"
        }
    }

    # deps
    provisioner "shell" {
        inline = [
            # "apt install -y libfreetype6-dev libmcrypt-dev php-bcmath php-mysql pdo_mysql php-zip php-gd",
            "apt install -y libfreetype6-dev libmcrypt-dev php-bcmath php-mysql php-zip php-gd php5.6-xml php5.6-mbstring php5.6-curl",
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }
    }

    # libjpeg62-turbo-dev
    # provisioner "shell" {
    #     inline = [
    #         "apt install -y libjpeg62-turbo-dev",
    #     ]
    # }

    # libpng12
    provisioner "shell" {
        inline = [
            "apt install -y build-essential zlib1g-dev",
            "mkdir /devops/tools/libpng12",
            "cd /devops/tools/libpng12",
            "mkdir src",
            "wget https://ppa.launchpadcontent.net/linuxuprising/libpng12/ubuntu/pool/main/libp/libpng/libpng_1.2.54.orig.tar.xz",
            "tar Jxfv libpng_1.2.54.orig.tar.xz",
            "cd libpng-1.2.54",
            "./configure",
            "make",
            "make install",
            "ln -s /usr/local/lib/libpng12.so.0.54.0 /usr/lib/libpng12.so",
            "ln -s /usr/local/lib/libpng12.so.0.54.0 /usr/lib/libpng12.so.0",
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }
    }

    # composer
    provisioner "shell" {
        inline = [
            "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"
        ]
    }

    # pecl
    provisioner "shell" {
        inline = [
            "apt install -y php-pear"
        ]
        env = {
            DEBIAN_FRONTEND = "noninteractive",
        }
    }



    post-processors {
        post-processor "docker-import" {
            repository = "vinik/pp"
            tag = var.version
        }
        post-processor "docker-push" {}
        post-processor "docker-tag" {
            repository = "vinik/pp"
            tag = ["latest"]
        }
        post-processor "docker-push" {}
    }
}

