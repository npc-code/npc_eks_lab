variable "base_network" {
  type        = string
  description = "base network address, e.g. 10.100.0.0"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "environment" {
  type        = string
  description = "environment to deploy to"
}

variable "external_ip" {
  type        = string
  description = "ip to use for external access.  used to control where api endpoint can be reached from"
}

variable "network_mask" {
  type    = number
  default = 16
}

variable "pod_sg_example" {
  type    = bool
  default = false
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

variable "eks_version" {
  type        = string
  default     = "1.19"
  description = "k8s version to use in eks cluster"
}
