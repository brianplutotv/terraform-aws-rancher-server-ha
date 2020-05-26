locals {
  # Deployment name
  name = var.name

  # Tags
  common_tags = var.custom_tags

  # keys
  key_path = var.key_path

  # Nodes
  instance_count = 3
  instance_type  = var.instance_type
  instance_user  = "ubuntu"

  # elb
  internal_lbs  = var.internal_lbs

  # API Server load balancer
  api_server_hostname = aws_lb.rancher_api.dns_name
  api_server_url      = "https://${aws_lb.rancher_api.dns_name}"

  # Domain
  domain = var.domain

  ### RKE

  # Default to main aws region for backups unless overridden
  rke_backup_region = length(var.rke_backups_region) > 0 ? var.rke_backups_region : var.aws_region

  # Default to S3 endpoint for region unless overridden
  rke_backup_endpoint = length(var.rke_backups_s3_endpoint) > 0 ? var.rke_backups_s3_endpoint : "s3.${local.rke_backup_region}.amazonaws.com"

  ### Rancher

  certmanager_chart        = var.certmanager_chart
  certmanager_version      = var.certmanager_version
  rancher_chart            = var.rancher_chart
  rancher_version          = var.rancher_version
  le_email                 = var.le_email
  rancher_current_password = var.rancher_current_password
  rancher_password         = var.rancher_password
}
