resource "aws_security_group" "bastion" {
  name_prefix = "bastion.${var.name}.${terraform.workspace}"
  description = "bastion.${var.name}.${terraform.workspace}"
  vpc_id      = module.vpc.id

  tags = merge({
    Name = "bastion.${var.name}.${terraform.workspace}"
    Environment     = terraform.workspace
  }, var.tags)
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_ingress_self" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  count                    = length(var.allowed_cidrs)
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = lookup(var.allowed_cidrs[count.index], "cidr_blocks", null)
  description              = lookup(var.allowed_cidrs[count.index], "description", null)
  source_security_group_id = lookup(var.allowed_cidrs[count.index], "source_security_group_id", null)
  self                     = lookup(var.allowed_cidrs[count.index], "self", null)
  security_group_id        = aws_security_group.bastion.id
}

resource "aws_eip" "bastion" {
  vpc      = true
  instance = aws_instance.bastion.id

  tags = merge({
    Name = "bastion.${var.name}.${terraform.workspace}"
    Environment     = terraform.workspace
  }, var.tags)
}

resource "aws_key_pair" "main" {
  key_name_prefix   = terraform.workspace == "default" ? "insecure.${var.name}.${terraform.workspace}." : "${var.name}.${terraform.workspace}."
  public_key        = terraform.workspace == "default" ? file("ssh_keys/insecure.pub") : file("ssh_keys/${terraform.workspace}.pub")
}


resource "aws_iam_role" "bastion" {
  name_prefix = "bastion.${var.name}.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = aws_iam_role.bastion.name
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy_attachment" "BastionAmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.name
}

data "template_cloudinit_config" "config" {
  gzip            = false
  base64_encode   = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("files/bastion-userdata.tpl", {})

  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon.image_id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [ aws_security_group.bastion.id, module.vpc.default_sg ]
  subnet_id              = module.vpc.public_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  user_data_base64       = data.template_cloudinit_config.config.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }

  volume_tags = merge({
      Name   = "bastion.${var.name}.${terraform.workspace}"
      Environment       = terraform.workspace
    }, var.tags)

  tags = merge({
    Name = "bastion.${var.name}.${terraform.workspace}"
    Environment     = terraform.workspace
    }, var.tags)

  lifecycle {
    ignore_changes = [ami]
  }
}
