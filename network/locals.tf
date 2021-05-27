locals {
  base_cidr   = "${var.base_network}/${var.network_mask}"
  new_bits    = var.subnet_mask - var.network_mask
  num_subnets = length(var.azs)
}