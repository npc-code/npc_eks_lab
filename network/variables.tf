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

variable "eks_generated_sg" {
  type        = string
  description = "eks generated security group id"
}

variable "external_ip" {
    type = string
    description = "ip range to allow access from for alb"
}

variable "network_mask" {
  type    = number
  default = 16
}

variable "subnet_mask" {
  type    = number
  default = 24
}