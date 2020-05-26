### Elastic LB

resource "aws_security_group" "rancher_elb" {
  name   = "${local.name}-elb"
  vpc_id = data.aws_vpc.app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "rancher" {
  name            = local.name
  internal        = local.internal_lbs
  subnets         = data.aws_subnet_ids.app.ids
  security_groups = [aws_security_group.rancher_elb.id]
  instances       = aws_instance.rancher_node.*.id

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "tcp:80"
    interval            = 5
  }
  idle_timeout = 1800

  tags = local.common_tags
}

### LB for Rancher API

resource "aws_lb" "rancher_api" {
  name_prefix        = "rancha"
  internal        = local.internal_lbs
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.app.ids

  enable_deletion_protection = false # was true

  tags = merge({ Name = "${local.name}-api" }, local.common_tags)
}

resource "aws_lb_listener" "rancher_api_https" {
  load_balancer_arn = aws_lb.rancher_api.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_api.arn
  }
}

resource "aws_lb_listener" "rancher_api_https2" {
  load_balancer_arn = aws_lb.rancher_api.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_api.arn
  }
}

resource "aws_lb_target_group" "rancher_api" {
  name_prefix = "rancha"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.app.id
}

resource "aws_lb_target_group_attachment" "rancher_api" {
  count            = local.instance_count
  target_group_arn = aws_lb_target_group.rancher_api.arn
  target_id        = aws_instance.rancher_node[count.index].id
}
