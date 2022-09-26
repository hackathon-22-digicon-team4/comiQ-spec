variable "cidr_block_vpc" {}
variable "stage" {}
variable "project" {}
variable "cidr_block_public_1a" {}
variable "cidr_block_public_1c" {}
variable "cidr_block_private_1a" {}
variable "cidr_block_private_1c" {}
variable "az_1a" {}
variable "az_1c" {}
output "sg_for_alb" { value = aws_security_group.for_alb }
output "sg_for_ecs" { value = aws_security_group.for_ecs }
output "sg_for_rds" { value = aws_security_group.for_rds }
output "sg_for_ssh" { value = aws_security_group.for_ssh }
