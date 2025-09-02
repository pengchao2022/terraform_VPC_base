variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC (for tagging)"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}