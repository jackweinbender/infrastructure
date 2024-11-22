resource "aws_key_pair" "aws-default" {
  key_name   = "aws-default"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFcy0CTejARSO2ni1dDTMkcFJh1SBCjAiZ5Nql5nlGbg"
}

# module "ec2" {
#   source        = "./modules/debian"
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.aws-default.key_name
#   subnet_id     = aws_subnet.default.id
#   userdata      = templatefile("userdata.tftpl", { tailscale_auth_key = var.tailscale_auth_key })
#   vpc_security_group_ids = [
#     aws_default_security_group.default.id
#   ]
# }
