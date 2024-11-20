variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = set(string)
}

variable "tailscale_auth_key" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "aws-default"
}
