# Spot Instances
resource "aws_instance" "benchmarker" {
  count = var.instance_count

  ami = "ami-03bbe60df80bdccc0"
  instance_type = var.instance_type

  # instance_market_options {
  #   market_type = "spot"
  #   spot_options {
  #     max_price = var.max_price
  #   }
  # }

  user_data = <<EOF
#!/bin/bash
curl https://github.com/${var.github_username}.keys >> /home/ubuntu/.ssh/authorized_keys

/bin/sed -i -e "s/#Port 22/Port 20340/" /etc/ssh/sshd_config
systemctl restart sshd
  EOF

  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group_id ]

  tags = merge(var.tags, {
    Name = "benchmarker-${count.index + 1}"
  })
}