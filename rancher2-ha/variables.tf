variable "name" {
  description = "Name of deployment (e.g. rancher, rancher-prod)"
  default     = "rancher"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "app_vpc_tags" {
  description = "VCP id tags for application."
  type        = map(string)
  default     = { Name = "DEV" }
}

variable "app_subnet_tags" {
  description = "VCP id tags for application."
  type        = map(string)
  default     = { purpose_app = true }
}

// variable "dmz_subnet_tags" {
//   description = "VCP id tags for application."
//   type = map(string)
//   default = {purpose_dmz = true}
// }

variable "key_path" {
  description = "Path to save the id_rsa config file. Should end in a forward slash `/` ."
  type        = string
  default     = "./secret_files"
}

variable "extra_ssh_keys" {
  description = "List of sxtra ssh keys to inject into Rancher instances."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Node instance type to deploy Rancher to.  Should be sized appropriatley to Rancher recommendations."
  type        = string
  default     = "t3.large"
}

variable "instance_amis" {
  description = "Instance image"
  type        = map(string)
  default = {
    us-east-2 = "ami-0516c27447372d3e5" // ubuntu-minimal/images/hvm-ssd/ubuntu-bionic-18.04-amd64-minimal-2020
  }
}

variable "internal_lbs" {
  description = "Use internal LBs (instead of ones connected to Internet Gateway)"
  type        = bool
  default     = false
}

variable "domain" {
  description = "DNS domain for Route53 zone.  Example rancher.nuarch.space."
  type        = string
}

variable "custom_tags" {
  description = "Custom tags for Rancher resources."
  default = {
    "Purpose" : "Operations"
    "Project" : "Rancher"
    "Environment" : "DEV"
    "Owner" : "DevOps"
  }
}

variable "rke_backups_region" {
  description = "Region to perform backups to S3 in. Defaults to aws_region"
  type        = string
  default     = ""
}

variable "rke_backups_s3_endpoint" {
  description = "Override for S3 endpoint to use for backups"
  type        = string
  default     = ""
}

### Rancher

variable "certmanager_chart" {
  description = "Helm chart to use for cert-manager install."
  type        = string
  default     = "jetstack/cert-manager"
}

variable "certmanager_version" {
  description = "Version of cert-manager to install."
  type        = string
  default     = "0.14.0"
}

variable "rancher_chart" {
  description = "Helm chart to use for Rancher install."
  type        = string
  default     = "rancher-stable/rancher"
}

variable "rancher_version" {
  description = "Version of Rancher to install."
  type        = string
  default     = "2.3.5"
}

variable "le_email" {
  description = "LetsEncrypt email address to use."
  type        = string
  default     = "none@none.com"
}

variable "rancher_current_password" {
  description = "Rancher admin user current password."
  type        = string
  default     = null
}

variable "rancher_password" {
  description = "Password to set for Rancher root user."
  type        = string
}
