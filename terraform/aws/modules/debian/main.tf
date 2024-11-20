
resource "aws_instance" "this" {
  ami                    = local.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  metadata_options {
    http_tokens = "required"
  }
  user_data = <<-EOT
    #cloud-config
    ssh_pwauth: false
    users:
    - name: ansible
      gecos: Ansible User
      groups: users,admin,wheel
      sudo: ALL=(ALL) NOPASSWD:ALL
      shell: /bin/bash
      lock_passwd: true
    runcmd:
      - curl -fsSL https://tailscale.com/install.sh | sh
      - ['sh', '-c', "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && sudo sysctl -p /etc/sysctl.d/99-tailscale.conf" ]
      - tailscale up --ssh --accept-routes --authkey=${var.tailscale_auth_key}
  EOT
}
