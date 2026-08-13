# Variables for the Route Table Subnet Association module.
variable "subnet_id" {
  description = "The ID of the subnet to which the Route Table will be associated."
  type        = string
}

variable "route_table_id" {
  description = "The ID of the Route Table to be associated with the subnet."
  type        = string
}