resource "aws_key_pair" "main" {
  key_name_prefix   = terraform.workspace == "default" ? "insecure.${var.name}.${terraform.workspace}." : "${var.name}.${terraform.workspace}."
  public_key        = terraform.workspace == "default" ? file("ssh_keys/insecure.pub") : file("ssh_keys/${terraform.workspace}.pub")
}

resource "aws_iam_role" "provisioner" {
  name_prefix = "provisioner.${var.name}.${local.environment}."

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

  user_data = file("./provisioners/provisioner.sh")

  volume_tags = merge({
      Name        = "provisioner.${var.name}.${local.environment}"
      Environment = local.environment
    }, var.tags)

  tags = merge({
      Name        = "provisioner.${var.name}.${local.environment}"
    Environment = local.environment
  }, var.tags)

  lifecycle {
    ignore_changes = [ami]
  }
}
