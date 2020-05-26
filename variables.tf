variable "instance_amis" {
  description = "Instance image"
  type        = map(string)
  default = {
    us-east-2 = "ami-0516c27447372d3e5" // ubuntu-minimal/images/hvm-ssd/ubuntu-bionic-18.04-amd64-minimal-2020
  }
}
