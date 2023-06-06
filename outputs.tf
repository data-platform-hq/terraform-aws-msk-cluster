output "arn" {
  description = "Amazon Resource Name (ARN) of the MSK cluster"
  value       = var.cluster_type == "provisioned" ? try(aws_msk_cluster.this[0].arn, null) : try(aws_msk_serverless_cluster.this[0].arn, null)
}

output "bootstrap_brokers" {
  description = "Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers, null)
}

output "bootstrap_brokers_public_sasl_iam" {
  description = "One or more DNS names (or IP addresses) and SASL IAM port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_public_sasl_iam, null)
}

output "bootstrap_brokers_public_sasl_scram" {
  description = "One or more DNS names (or IP addresses) and SASL SCRAM port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_public_sasl_scram, null)
}

output "bootstrap_brokers_public_tls" {
  description = "One or more DNS names (or IP addresses) and TLS port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_public_tls, null)
}

output "bootstrap_brokers_sasl_iam" {
  description = "One or more DNS names (or IP addresses) and SASL IAM port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_iam, null)
}

output "bootstrap_brokers_sasl_scram" {
  description = "One or more DNS names (or IP addresses) and SASL SCRAM port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_sasl_scram, null)
}

output "bootstrap_brokers_tls" {
  description = "One or more DNS names (or IP addresses) and TLS port pairs"
  value       = try(aws_msk_cluster.this[0].bootstrap_brokers_tls, null)
}

output "current_version" {
  description = "Current version of the MSK Cluster used for updates"
  value       = try(aws_msk_cluster.this[0].current_version, null)
}

output "zookeeper_connect_string" {
  description = "A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = try(aws_msk_cluster.this[0].zookeeper_connect_string, null)
}
