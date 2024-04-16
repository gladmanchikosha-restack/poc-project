# VPC resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "${var.name_prefix}-poc"
    Schedule  = "no-schedule"
    Createdby = "gladmanchikosha"
  }
}

#Name prefix variable
variable "name_prefix" {
  type        = string
  description = "Identifier"
  default     = "GC"
}