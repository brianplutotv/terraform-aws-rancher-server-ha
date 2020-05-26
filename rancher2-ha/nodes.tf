resource "aws_security_group" "rancher" {
  name   = "${local.name}-node"
  vpc_id = data.aws_vpc.app.id

  # Inbound TCP (SSH) access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTT{} access from ELB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = [aws_security_group.rancher_elb.id]
  }

  # Inbound TCP (HTTPS) access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbouncd TCP access from anywhere
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound access from this security group (all protocols)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Outbound access to web (all protocols)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Operating System for nodes

resource "aws_instance" "rancher_node" {
  count         = local.instance_count
  ami           = lookup(var.instance_amis, var.aws_region)
  instance_type = local.instance_type
  key_name      = aws_key_pair.ssh.id
  user_data     = templatefile("${path.module}/../config-files/cloud-config.yaml", { extra_ssh_keys = var.extra_ssh_keys })

  vpc_security_group_ids      = [aws_security_group.rancher.id]
  subnet_id                   = tolist(data.aws_subnet_ids.app.ids)[count.index]
  associate_public_ip_address = true

  root_block_device {
    encrypted   = true
    volume_type = "gp2" # General purpose SSD
    volume_size = "50"  # 50 GiB
  }

  tags = merge({ Name = "${local.name}-node" }, local.common_tags)
}
