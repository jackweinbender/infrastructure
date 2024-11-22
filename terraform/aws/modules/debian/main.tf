
resource "aws_instance" "this" {
  ami                         = local.images.debian
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = var.vpc_security_group_ids
  metadata_options {
    http_tokens = "required"
  }
  user_data = var.userdata
}
