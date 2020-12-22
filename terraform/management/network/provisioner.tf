resource "aws_security_group" "provisioner" {
  name_prefix = "provisioner.${var.name}.${terraform.workspace}"
  description = "provisioner.${var.name}.${terraform.workspace}"
  vpc_id      = module.vpc.id

  tags = merge({
      Name = "provisioner.${var.name}.${terraform.workspace}"
      Environment     = terraform.workspace
    }, var.tags)
}

resource "aws_security_group_rule" "provisioner_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "provisioner_ingress_self" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.provisioner.id
}

resource "aws_security_group_rule" "provisioner_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "allow from bastion"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.provisioner.id
}

resource "aws_iam_role" "provisioner" {
  name_prefix = "provisioner.${var.name}.${lookup(var.workspace_shortcode, terraform.workspace, terraform.workspace)}."

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

resource "aws_iam_instance_profile" "provisioner" {
  name = aws_iam_role.provisioner.name
  role = aws_iam_role.provisioner.name
}

resource "aws_iam_role_policy_attachment" "ProvisionerAmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.provisioner.name
}

resource "aws_instance" "provisioner" {
  ami                    = data.aws_ami.amazon.image_id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [ aws_security_group.provisioner.id, module.vpc.default_sg ]
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.provisioner.name

  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }

  user_data = file("./files/provisioner-userdata.sh")

  volume_tags = merge({
      Name = "provisioner.${var.name}.${terraform.workspace}"
      Environment     = terraform.workspace
    }, var.tags)

  tags = merge({
      Name = "provisioner.${var.name}.${terraform.workspace}"
      Environment     = terraform.workspace
    }, var.tags)

  lifecycle {
    ignore_changes = [ami]
  }
}
