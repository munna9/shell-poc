data "aws_route53_zone" "selected" {
  name         = var.route53_zone
}
data "aws_availability_zones" "azs" {
}

provider "aws" {
  region = var.aws_region
}
resource "aws_security_group" "openvpn" {
  name        = var.name
  vpc_id      = aws_vpc.main.id
  description = "OpenVPN security group"
  tags = {
    Name = var.name
  }
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  # For OpenVPN Client Web Server & Admin Web UI
  ingress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "UDP"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "TCP"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "TCP"
    from_port   = 943
    to_port     = 943
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "TCP"
    from_port   = 945
    to_port     = 945
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "openvpn_data" {
  count                   = var.instance_count
  availability_zone       = element(var.availability_zone, count.index)
  size                    = var.ebs_size
  encrypted               = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_key_pair" "openvpnkey" {
  key_name   = "openvpnkey"
  public_key = file("openvpnkey.pub")
}

resource "aws_instance" "openvpn" {
  count                       = var.instance_count
  availability_zone           = element(var.availability_zone, count.index)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.openvpnkey.key_name
  subnet_id                   = aws_subnet.subnets.*.id[count.index]
  vpc_security_group_ids      = [aws_security_group.openvpn.id]
  associate_public_ip_address = true
  tags = merge({
    Name         = "${var.name}.${terraform.workspace}"
    Envinronment = terraform.workspace
  }, var.tags)
  # `admin_user` and `admin_pw` need to be passed in to the appliance through `user_data`, see docs -->
  # https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/
  user_data = <<USERDATA
public_hostname=${var.public_dns_name}
admin_user=${var.admin_user}
admin_pw=${var.admin_password}
reroute_gw=1
reroute_dns=1
USERDATA
}

resource "aws_volume_attachment" "ebs_att" {
  count                       = var.instance_count
  device_name = "/dev/sdh"
  instance_id = aws_instance.openvpn.*.id[count.index]
  volume_id   = aws_ebs_volume.openvpn_data.*.id[count.index]
}

//resource "aws_route53_zone" "r53zone" {
//  name = var.route54_zone
//}

resource "aws_route53_record" "openvpn" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.public_dns_name
  type    = "A"
  ttl     = "300"
  records = aws_instance.openvpn.*.public_ip
}

resource "aws_lb" "nlb" {
  name               = "vpn-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.subnets.*.id
  enable_deletion_protection = false

  tags = {
    Environment = "stage"
  }
}

resource "aws_lb_target_group" "vpn" {
  name     = "openvpn"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
  depends_on = [aws_lb.nlb]
  stickiness {
    enabled = false
    type = "lb_cookie"
  }
}

resource "aws_lb_target_group_attachment" "vpn" {
  count             = var.instance_count
  target_group_arn = aws_lb_target_group.vpn.arn
  target_id        = aws_instance.openvpn.*.id[count.index]
  port             = 443
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpn.arn
  }
}

# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = aws_lb_listener.front_end.arn
#   certificate_arn = aws_acm_certificate.cert.arn
# }

resource "aws_acm_certificate" "cert" {
  domain_name       = var.public_dns_name
  validation_method = "DNS"

  tags = {
    Environment = "stage"
  }

  lifecycle {
    create_before_destroy = true
  }
}