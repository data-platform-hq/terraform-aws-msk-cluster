locals {
  client_authentication_enabled = var.client_authentication_sasl_enabled || var.client_authentication_tls_enabled || var.client_authentication_unauthenticated_enabled ? true : false
  server_properties             = join("\n", [for k, v in var.mks_configuration_server_properties : format("%s = %s", k, v)])
}

################################################################################
# Provisioned MSK cluster
################################################################################
resource "aws_msk_cluster" "this" {
  count                  = var.create && var.cluster_type == "provisioned" ? 1 : 0
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring
  tags                   = var.tags

  broker_node_group_info {
    client_subnets  = var.client_subnets
    instance_type   = var.instance_type
    security_groups = concat(aws_security_group.this[*].id, var.additional_security_groups)
    az_distribution = var.az_distribution_enabled ? "DEFAULT" : null
    dynamic "connectivity_info" {
      for_each = var.public_access_type_enabled ? [1] : []
      content {
        public_access {
          type = "SERVICE_PROVIDED_EIPS"
        }
      }
    }
    dynamic "storage_info" {
      for_each = var.ebs_storage_info_enabled ? [1] : []
      content {
        ebs_storage_info {
          dynamic "provisioned_throughput" {
            for_each = var.ebs_storage_info.provisioned_throughput_enabled ? [1] : []
            content {
              enabled           = true
              volume_throughput = var.ebs_storage_info.provisioned_throughput_volume_throughput
            }
          }
          volume_size = var.ebs_storage_info.volume_size
        }
      }
    }
  }

  dynamic "client_authentication" {
    for_each = local.client_authentication_enabled ? [1] : []
    content {
      unauthenticated = var.client_authentication_unauthenticated_enabled
      dynamic "sasl" {
        for_each = var.client_authentication_sasl_enabled ? [1] : []
        content {
          iam   = var.client_authentication_sasl_iam
          scram = var.client_authentication_sasl_scram
        }
      }

      dynamic "tls" {
        for_each = var.client_authentication_tls_enabled ? [1] : []
        content {
          certificate_authority_arns = var.client_authentication_tls_certificate_authority_arns
        }
      }
    }
  }

  dynamic "configuration_info" {
    for_each = var.msk_configuration_enabled ? [1] : [0]
    content {
      arn      = aws_msk_configuration.this[0].arn
      revision = aws_msk_configuration.this[0].latest_revision
    }
  }

  dynamic "encryption_info" {
    for_each = var.encryption_enabled ? [1] : []
    content {
      encryption_in_transit {
        client_broker = var.encryption_config.encryption_in_transit_client_broker
        in_cluster    = var.encryption_config.encryption_in_transit_in_cluster
      }
      encryption_at_rest_kms_key_arn = var.encryption_config.encryption_at_rest_kms_key_arn
    }
  }

  dynamic "open_monitoring" {
    for_each = var.open_monitoring_enabled ? [1] : []
    content {
      prometheus {
        jmx_exporter {
          enabled_in_broker = var.open_monitoring_config.jmx_exporter_enabled_in_broker
        }
        node_exporter {
          enabled_in_broker = var.open_monitoring_config.node_exporter_enabled_in_broker
        }
      }
    }
  }

  dynamic "logging_info" {
    for_each = var.logging_enabled ? [1] : []
    content {
      broker_logs {
        dynamic "cloudwatch_logs" {
          for_each = var.logging_cloudwatch.enabled ? [1] : []
          content {
            enabled   = true
            log_group = var.logging_cloudwatch.log_group
          }
        }
        dynamic "firehose" {
          for_each = var.logging_firehose.enabled ? [1] : []
          content {
            enabled         = true
            delivery_stream = var.logging_firehose.delivery_stream
          }
        }
        dynamic "s3" {
          for_each = var.logging_s3.enabled ? [1] : [0]
          content {
            enabled = true
            bucket  = var.logging_s3.bucket
            prefix  = var.logging_s3.prefix
          }
        }
      }
    }
  }
  lifecycle {
    precondition {
      condition     = var.kafka_version != ""
      error_message = "kafka_version shouldn't be empty if cluster_type is provisioned"
    }
    precondition {
      condition     = var.number_of_broker_nodes != null
      error_message = "number_of_broker_nodes shouldn't be empty if cluster_type is provisioned"
    }
    precondition {
      condition     = var.instance_type != ""
      error_message = "instance_type shouldn't be empty if cluster_type is provisioned"
    }
  }
}

resource "aws_msk_configuration" "this" {
  count          = var.create && var.msk_configuration_enabled && var.cluster_type == "provisioned" ? 1 : 0
  kafka_versions = [var.kafka_version]
  name           = "${var.cluster_name}-config"

  server_properties = local.server_properties
}

################################################################################
# Serverless MSK cluster
################################################################################
resource "aws_msk_serverless_cluster" "this" {
  count        = var.create && var.cluster_type == "serverless" ? 1 : 0
  cluster_name = var.cluster_name
  tags         = var.tags

  vpc_config {
    subnet_ids         = var.client_subnets
    security_group_ids = concat(aws_security_group.this[*].id, var.additional_security_groups)
  }

  client_authentication {
    sasl {
      iam {
        enabled = var.client_authentication_sasl_iam_enabled
      }
    }
  }
}

resource "aws_msk_scram_secret_association" "this" {
  count           = var.create && var.secret_association_enabled ? 1 : 0
  cluster_arn     = var.cluster_type == "provisioned" ? aws_msk_cluster.this[0].arn : aws_msk_serverless_cluster.this[0].arn
  secret_arn_list = var.secret_arn_list
}
