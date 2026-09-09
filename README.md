# Packer Base Images

This repository contains HashiCorp Packer templates used to build and maintain a set of standardized base images for both Google Compute Engine (GCE) and Docker.

## 📦 Image Catalog

### 1. Base Image (`base.pkr.hcl`)
The foundation for all other images. It ensures a clean, updated Ubuntu 24.04 LTS environment.
- **Targets**: Google Compute Engine, Docker.
- **Key Actions**: System updates and upgrades.
- **Outputs**: 
  - GCE: `${my_prefix}-base` image family.
  - Docker: `vinik/base` image.

### 2. DevOps Box (`devopsbox.pkr.hcl`)
A toolkit image designed for infrastructure engineers.
- **Targets**: Docker.
- **Base**: `vinik/base:0.1.0`.
- **Included Tools**: 
  - Docker
  - Packer
  - kubectl
  - curl, unzip.
- **Outputs**: `vinik/devopsbox` image.

### 3. Nomad Node (`nomad.pkr.hcl`)
A specialized image for running HashiCorp Nomad clusters on GCP.
- **Targets**: Google Compute Engine.
- **Base**: `base` GCE image family.
- **Included Tools**: 
  - HashiCorp Nomad
  - Docker.
- **Outputs**: GCE image in the `${my_prefix}` family.

### 4. PHP Legacy Stack (`pp.pkr.hcl`)
A specialized Docker image for legacy PHP 5.6 applications.
- **Targets**: Docker.
- **Base**: `vinik/base:0.1.0`.
- **Included Stack**: 
  - Apache2
  - PHP 5.6 (via ondrej/php PPA)
  - PHP Extensions: `bcmath`, `mysql`, `zip`, `gd`, `xml`, `mbstring`, `curl`.
  - Composer & PEAR.
  - libpng12 (compiled from source for legacy compatibility).
  - Timezone: `America/Sao_Paulo`.
- **Outputs**: `vinik/pp` image.

## 🚀 Getting Started

### Prerequisites
- [Packer](https://developer.hashicorp.com/packer/downloads) installed.
- A Google Cloud Project with appropriate permissions.
- A Docker Hub account.

### Building Images

#### Base Image
```bash
packer init base.pkr.hcl
packer build \
  -var 'gcp_project_id=YOUR_PROJECT_ID' \
  -var 'gcp_credentials_json=YOUR_JSON_KEY' \
  -var 'my_prefix=ckrst' \
  -var 'docker_hub_username=YOUR_USERNAME' \
  -var 'docker_hub_password=YOUR_PASSWORD' \
  base.pkr.hcl
```

#### Nomad Image
```bash
packer init nomad.pkr.hcl
packer build \
  -var 'gcp_project_id=YOUR_PROJECT_ID' \
  -var 'gcp_credentials_json=YOUR_JSON_KEY' \
  -var 'my_prefix=ckrst' \
  nomad.pkr.hcl
```

#### Specialized Docker Images
```bash
packer build devopsbox.pkr.hcl
packer build pp.pkr.hcl
```

## 🛠 CI/CD
The project includes a GitHub Actions workflow (`.github/workflows/main.yml`) that:
1. **Validates** all templates on every push or pull request to `main`.
2. **Builds** the `base` and `nomad` images automatically in the `prod` environment.

## 📄 License
Refer to the `LICENSE` file for details.
