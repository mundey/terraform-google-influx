# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "ID of the GCP Project where all resources will be launched."
}

variable "name_prefix" {
  description = "This variable is used to namespace all resources created by this module."
}

variable "target_tags" {
  description = "The target tags define the compute instances to which the rules apply."
  type        = "list"
}

variable "network" {
  description = "The name or self link of the VPC network in which to deploy the InfluxDB cluster"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "ports" {
  description = "An optional list of ports or port ranges to which this rule applies. If not specified, this rule applies to connections through any port."
  type        = "list"
  default     = []
}

variable "protocol" {
  description = "The IP protocol to which this rule applies."
  default     = "tcp"
}

variable "allow_access_from_cidr_blocks" {
  description = "The list of CIDR-formatted IP address ranges from which access will be allowed."
  type        = "list"
  default     = []
}
