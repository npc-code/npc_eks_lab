variable "azs" {
  type        = list(any)
  description = "list of availability zones to use"
}

variable "base_network" {
  type        = string
  description = "base network address, e.g. 10.100.0.0"
}

variable "eks_cluster_name" {
  type        = string
  description = "eks cluster name"
}

variable "network_mask" {
  type    = number
  default = 16
}

variable "subnet_mask" {
  type    = number
  default = 24
}