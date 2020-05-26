module "rancher_ha_deployment" {
  source = "./rancher2-ha"

  aws_profile = "default"
  aws_region  = "us-east-2"
  app_vpc_tags = {
    "Name" : "DEV"
  }
  custom_tags = {
    "Purpose" : "Operations"
    "Project" : "Rancher"
    "Environment" : "DEV"
    "Owner" : "DevOps"
  }

  internal_lbs     = false
  domain           = "rancher.dsvmacdonald.space"
  instance_type    = "t3.large"
  name             = "rancher"
  rancher_password = "admin"
  instance_amis    = var.instance_amis
}
