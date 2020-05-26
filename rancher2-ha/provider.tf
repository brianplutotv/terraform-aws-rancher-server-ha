provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  version = "2.54.0"
}

provider "aws" {
  alias  = "r53"
  region = var.aws_region
}

provider "rke" {
}

provider "helm" {
  version = "= 1.1.0"

  kubernetes {
    config_path = local_file.kube_cluster_yaml.filename
  }
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${local.domain}"
  bootstrap = true
}

provider "rancher2" {
  api_url   = "https://${local.domain}"
  token_key = rancher2_bootstrap.admin.token
}
