data "aws_vpc" "app" {
  default = false
  state   = "available"
  tags    = var.app_vpc_tags
}

data "aws_subnet_ids" "app" {
  vpc_id = data.aws_vpc.app.id
  tags   = var.app_subnet_tags
}

// data "aws_subnet_ids" "dmz" {
//   vpc_id = data.aws_vpc.app.id
//   tags = var.dmz_subnet_tags
// }
