resource "aws_db_subnet_group" "main" {
  name_prefix = "${var.name}-"
  description = "subnet group for ${var.name}"
  subnet_ids  = var.subnets

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )
}

resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.name}-"
  description = "option group for ${var.name}"
  family      = lookup(var.engine, "family")

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_db_option_group" "main" {
  name_prefix              = "${var.name}-"
  option_group_description = "option group for ${var.name}"
  engine_name              = lookup(var.engine, "name")
  major_engine_version     = lookup(var.engine, "major_engine_version")

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "major_engine_version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

/*
resource "random_password" "main" {
  length = 16
  special = false
}
*/

resource "aws_db_instance" "main" {
  identifier                            = var.name
  engine                                = lookup(var.engine, "name", null)
  engine_version                        = lookup(var.engine, "version", null)
  instance_class                        = var.instance_class

  allocated_storage                     = lookup(var.storage, "allocated", null)
  storage_type                          = lookup(var.storage, "type", "gp2")
  iops                                  = lookup(var.storage, "iops", null)
  storage_encrypted                     = lookup(var.storage, "encrypted", false)
  kms_key_id                            = lookup(var.storage, "kms_key_id", null)

  name                                  = var.database_name
  username                              = var.database_username
  password                              = var.database_password

  port                                  = var.port
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled

  snapshot_identifier                   = var.snapshot_identifier
  vpc_security_group_ids                = var.security_group_ids
  db_subnet_group_name                  = aws_db_subnet_group.main.id
  parameter_group_name                  = aws_db_parameter_group.main.id
  option_group_name                     = aws_db_option_group.main.id
  availability_zone                     = var.availability_zone
  multi_az                              = var.multi_az
  publicly_accessible                   = var.publicly_accessible
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = coalesce(var.monitoring_role_arn, aws_iam_role.enhanced_monitoring.*.arn, null)
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  apply_immediately                     = var.apply_immediately
  skip_final_snapshot                   = var.skip_final_snapshot
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  final_snapshot_identifier             = var.final_snapshot_identifier
  max_allocated_storage                 = var.max_allocated_storage
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : null
  backup_retention_period               = var.backup_retention_period
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  deletion_protection                   = var.deletion_protection

  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )

  timeouts {
    create = lookup(var.timeouts, "create", null)
    delete = lookup(var.timeouts, "delete", null)
    update = lookup(var.timeouts, "update", null)
  }
}
