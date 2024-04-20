resource "aws_instance" "lamassu" {
  ami = "ami-0f58aa386a2280f35"
  instance_type = "t4g.small"
  
  associate_public_ip_address          = true
  availability_zone                    = "us-east-1b"
  disable_api_termination              = false
  ebs_optimized                        = true # forces replacement
  hibernation                          = false
  monitoring                           = false
  
  tags = {
    Name = "lamassu"
  }

  tags_all = {
    Name = "lamassu"
  }

  enclave_options {
    enabled = false 
  }

  metadata_options {
    http_endpoint               = "enabled" 
    http_put_response_hop_limit = 2 
    http_tokens                 = "required" 
  }


  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    tags                  = {}
    throughput            = 125
    volume_size           = 16
    volume_type           = "gp3"
  }

  timeouts {}
}