resource "aws_security_group" "tsdb" {
  name_prefix = "tsdb.${var.name}.${terraform.workspace}"
  description = "tsdb.${var.name}.${terraform.workspace}"
  vpc_id      = local.vpc.id

  tags = merge({
    Name        = "tsdb.${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)
}

resource "aws_security_group_rule" "tsdb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tsdb.id
}

resource "aws_security_group_rule" "tsdb_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.tsdb.id
}

resource "aws_security_group_rule" "tsdb_ingress_provisioner" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [ "${data.terraform_remote_state.management_network.outputs["provisioner_ip"]}/32" ]
  security_group_id = aws_security_group.tsdb.id
  description       = "allow ssh from management provisioner"
}

resource "aws_security_group_rule" "tsdb_ingress_postgres" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = [ data.terraform_remote_state.management_network.outputs["vpc_cidr"] ]
  security_group_id = aws_security_group.tsdb.id
  description       = "allow postgres from vpc"
}

resource "aws_security_group_rule" "tsdb_ingress_healthcheck" {
  type              = "ingress"
  from_port         = 8008
  to_port           = 8008
  protocol          = "tcp"
  cidr_blocks       = [ local.vpc.cidr ]
  security_group_id = aws_security_group.tsdb.id
  description       = "allow healthcheck from vpc"
}

resource "aws_iam_role" "tsdb" {
  name_prefix = "tsdb.${var.name}.${terraform.workspace}."

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

resource "aws_iam_instance_profile" "tsdb" {
  name = aws_iam_role.tsdb.name
  role = aws_iam_role.tsdb.name
}

resource "aws_iam_role_policy_attachment" "ProvisionerAmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.tsdb.name
}

resource "aws_s3_bucket" "tsdb" {
  bucket_prefix = "tsdb.${var.name}.${terraform.workspace}."
  acl    = "private"

  tags = merge({
    Name        = "tsdb.${var.name}.${terraform.workspace}.backup"
    Environment = terraform.workspace
  }, var.tags)
}

resource "aws_iam_user" "tsdb" {
  name = "tsdb.${var.name}.${terraform.workspace}"
  tags = merge({
    Name        = "tsdb.${var.name}.${terraform.workspace}.backup"
    Environment = terraform.workspace
  }, var.tags)
}

resource "aws_iam_access_key" "tsdb" {
  user = aws_iam_user.tsdb.name
}

resource "aws_iam_policy" "tsdb" {
  name_prefix = "tsdb.${var.name}.${terraform.workspace}."
  path        = "/"
  description = "Policy for TSDB to backup to s3 - pgbackrest"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.tsdb.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": ["${aws_s3_bucket.tsdb.arn}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "tsdb" {
  user       = aws_iam_user.tsdb.name
  policy_arn = aws_iam_policy.tsdb.arn
}

resource "aws_instance" "tsdb" {
  count                  = 3
  ami                    = var.tsdb_ami_id[var.region]
  instance_type          = "t3.medium"
  key_name               = data.terraform_remote_state.management_network.outputs["ssh_key_name"]
  vpc_security_group_ids = [ aws_security_group.tsdb.id, local.vpc.default_sg ]
  subnet_id              = element(local.vpc.private_subnets, count.index)
  iam_instance_profile   = aws_iam_instance_profile.tsdb.name

  root_block_device {
    volume_type = "gp2"
    volume_size = var.tsdb_volume_size
  }
  volume_tags = merge({
    Name        = "tsdb${count.index}.${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)

  tags = merge({
    Name        = "tsdb${count.index}.${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)

  provisioner "remote-exec" {
    inline = [ "echo dummy" ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.private_ip
      agent = true
    }
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "random_password" "tsdb_replicator" {
  length = 30
  special = false
}

resource "random_password" "tsdb_postgres" {
  length = 30
  special = false
}

resource "null_resource" "tsdb" {
  triggers = {
    tsdb_instance_ids = join(",", aws_instance.tsdb.*.id)
    #tsdb_volume_attachments = join(",", aws_volume_attachment.tsdb.*.id)
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${join(",",aws_instance.tsdb.*.private_ip)} --extra-vars 'pg_replicator_password=${random_password.tsdb_replicator.result} pg_postgres_password=${random_password.tsdb_postgres.result} pg_backup_bucket=${aws_s3_bucket.tsdb.id} patroni_scope=${var.name}-${terraform.workspace} pg_backup_aws_key=${aws_iam_access_key.tsdb.id} pg_backup_aws_secret=${aws_iam_access_key.tsdb.secret}' tsdb.yml"
    working_dir = "../../../ansible"
  }

  depends_on = [ aws_instance.tsdb ]
  #depends_on = [ aws_instance.tsdb,aws_volume_attachment.tsdb ]
}

resource "aws_lb" "tsdb" {
  name              = "tsdb-${var.name}-${terraform.workspace}"
  internal           = true
  load_balancer_type = "network"
  subnets            = local.vpc.private_subnets

  tags = merge({
    Name        = "tsdb.${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)

}

resource "aws_lb_target_group" "tsdb" {
  name        = "tsdb-${var.name}-${terraform.workspace}"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = local.vpc.id
}

resource "aws_lb_listener" "tsdb" {
  load_balancer_arn = aws_lb.tsdb.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tsdb.arn
  }
}

resource "aws_lb_target_group_attachment" "tsdb" {
  count            = length(aws_instance.tsdb.*.id)
  target_group_arn = aws_lb_target_group.tsdb.arn
  target_id        = element(aws_instance.tsdb.*.id, count.index)
  port             = 5000
}

/*
resource "aws_ebs_volume" "tsdb" {
  count             = length(aws_instance.tsdb.*.id)
  availability_zone = aws_instance.tsdb[count.index].availability_zone
  size              = 40

  tags = merge({
    Name        = "tsdb${count.index}.${var.name}.${terraform.workspace}"
    Environment = terraform.workspace
  }, var.tags)
}

resource "aws_volume_attachment" "tsdb" {
  count       = length(aws_instance.tsdb.*.id)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.tsdb[count.index].id
  instance_id = aws_instance.tsdb[count.index].id
}
*/
