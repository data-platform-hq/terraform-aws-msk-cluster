variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# MSK cluster
################################################################################
variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "cluster_type" {
  description = "Type of MSK cluster. Possible values: provisioned and serverless"
  type        = string

  validation {
    condition     = contains(["provisioned", "serverless"], var.cluster_type)
    error_message = "Valid values for var: cluster_type are (provisioned, serverless)"
  }
}

variable "client_subnets" {
  description = "A list of subnets to connect to in client VPC"
  type        = list(string)
}

variable "additional_security_groups" {
  description = "An additional list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster"
  type        = list(string)
  default     = []
}

variable "secret_association_enabled" {
  description = "Whether to enable SCRAM secrets association"
  type        = bool
  default     = false
}

variable "secret_arn_list" {
  description = "List of AWS Secrets Manager secret ARNs"
  type        = list(string)
  default     = []
}

################################################################################
# Serverless MSK cluster
################################################################################

variable "client_authentication_sasl_iam_enabled" {
  description = "Whether SASL/IAM authentication is enabled"
  type        = bool
  default     = false
}

################################################################################
# Provisioned MSK cluster
################################################################################

variable "kafka_version" {
  description = "Specify the desired Kafka software version"
  type        = string
  default     = ""

  #  validation {
  #    condition     = var.cluster_type == "provisioned" && var.kafka_version == "" ? false : true
  #    error_message = "kafka_version shouldn't be empty if cluster_type is provisioned"
  #  }
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets"
  type        = number
  default     = null

  #  validation {
  #    condition     = var.cluster_type == "provisioned" && var.number_of_broker_nodes == null ? false : true
  #    error_message = "number_of_broker_nodes shouldn't be empty if cluster_type is provisioned"
  #  }
}

variable "instance_type" {
  description = "Specify the instance type to use for the kafka brokers"
  type        = string
  default     = ""

  #  validation {
  #    condition     = var.cluster_type == "provisioned" && var.instance_type == "" ? false : true
  #    error_message = "instance_type shouldn't be empty if cluster_type is provisioned"
  #  }
}

variable "az_distribution_enabled" {
  description = "Whether to enable the distribution of broker nodes across availability zones"
  type        = bool
  default     = false
}

variable "public_access_type_enabled" {
  description = "Whether to enable public access. If enabled, will set public_access.type to SERVICE_PROVIDED_EIPS"
  type        = bool
  default     = false
}

variable "ebs_storage_info_enabled" {
  description = "Whether to enable configuration for storage volumes attached to MSK broker nodes"
  type        = bool
  default     = false
}

variable "ebs_storage_info" {
  description = "A block that contains EBS volume information"
  type = object({
    provisioned_throughput_enabled           = optional(bool, false)
    provisioned_throughput_volume_throughput = optional(number, null)
    volume_size                              = optional(number, null)
  })
  default = {}
}

variable "client_authentication_sasl_enabled" {
  description = "Whether to enable SASL client authentication"
  type        = bool
  default     = false
}

variable "client_authentication_sasl_iam" {
  description = "Enables IAM client authentication"
  type        = bool
  default     = false
}

variable "client_authentication_sasl_scram" {
  description = "Enables SCRAM client authentication via AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "client_authentication_tls_enabled" {
  description = "Whether to enable TLS client authentication"
  type        = bool
  default     = false
}

variable "client_authentication_tls_certificate_authority_arns" {
  description = "List of ACM Certificate Authority Amazon Resource Names"
  type        = list(string)
  default     = []
}

variable "client_authentication_unauthenticated_enabled" {
  description = "Whether to enable unauthenticated access"
  type        = bool
  default     = false
}

variable "msk_configuration_enabled" {
  description = "Whether to create MSK configuration"
  type        = bool
  default     = false
}

variable "mks_configuration_server_properties" {
  description = "A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
  type        = map(string)
  default     = {}
}

variable "encryption_enabled" {
  description = "Whether to enable encryption"
  type        = bool
  default     = false
}

variable "encryption_config" {
  description = "Encryption configuration"
  type = object({
    encryption_in_transit_enabled       = optional(bool, false)  # Whether to enable encryption in transit
    encryption_in_transit_client_broker = optional(string, null) # Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT
    encryption_in_transit_in_cluster    = optional(bool, null)   #  Whether data communication among broker nodes is encrypted
    encryption_at_rest_kms_key_arn      = optional(string, null) # You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest
  })
  default = {}
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level"
  type        = string
  default     = null
}

variable "open_monitoring_enabled" {
  description = "Whether to enable JMX and Node monitoring for the MSK cluster"
  type        = bool
  default     = false
}

variable "open_monitoring_config" {
  description = "Configuration for JMX and Node monitoring for the MSK cluster"
  type = object({
    jmx_exporter_enabled_in_broker  = optional(bool, false)
    node_exporter_enabled_in_broker = optional(bool, false)
  })
  default = {}
}

variable "logging_enabled" {
  description = "Whether to enable Broker Logs"
  type        = bool
  default     = false
}

variable "logging_cloudwatch" {
  description = "Configuration for streaming broker logs to Cloudwatch Logs"
  type = object({
    enabled   = optional(bool, false)  # Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs
    log_group = optional(string, null) # Name of the Cloudwatch Log Group to deliver logs to
  })
  default = {}
}

variable "logging_firehose" {
  description = "Configuration for streaming broker logs to Kinesis Data Firehose"
  type = object({
    enabled         = optional(bool, false)  # Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose
    delivery_stream = optional(string, null) # Name of the Kinesis Data Firehose delivery stream to deliver logs to
  })
  default = {}
}

variable "logging_s3" {
  description = "Configuration for streaming broker logs to S3"
  type = object({
    enabled = optional(bool, false)  # Indicates whether you want to enable or disable streaming broker logs to S3
    bucket  = optional(string, null) # Name of the S3 bucket to deliver logs to
    prefix  = optional(string, null) # Prefix to append to the folder name
  })
  default = {}
}
