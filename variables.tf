####################
# Input variables  #
####################

variable "aws_region" {
  type        = string
  default     = "us-west-2"
}

variable "infra-prefix" {
  type        = string
  default     = "ntr"
}

variable "instance_type" {
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  type        = string
}

variable "az" {
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.123.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.123.1.0/24"
}