variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "security_group_prefix" {
  description = "The prefix for the name of the security group"
  type        = string
  default     = "wordpress-sg-"
}

variable "ami_id" {
  description = "The ID of the AMI to use"
  type        = string
  default     = "ami-058909ec4e7c8a655" # Amazon Linux 2 AMI - Kernel 5.10
}

variable "key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
}

variable "instance_name" {
  description = "The name we want to call the instance"
  type        = string
}

variable "db_name" {
  description = "The name of the database to use with WordPress"
  type        = string
}

variable "db_user" {
  description = "The user for the database that WordPress will use"
  type        = string
}

variable "db_password" {
  description = "The password for the database user that WordPress will use"
  type        = string
}

variable "db_host" {
  description = "The host of the database that WordPress will use"
  type        = string
  default     = "localhost"
}

variable "certbot_email" {
  description = "The email you want to supply to certbot"
  type        = string
}

variable "certbot_domain" {
  description = "The domain you want to supply to certbot"
  type        = string
}
