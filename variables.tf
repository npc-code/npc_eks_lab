variable "base_network" {
  type        = string
  description = "base network address, e.g. 10.100.0.0"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
}

variable "environment" {
  type        = string
  description = "environment to deploy to"
}

variable "network_mask" {
  type    = number
  default = 16
}

variable "profile" {
  type        = string
  description = "aws profile to use"
  default     = ""
}

variable "region" {
  type        = string
  description = "aws region to deploy to"
  default     = "us-east-1"
}

variable "subnet_mask" {
  type    = number
  default = 24
}
