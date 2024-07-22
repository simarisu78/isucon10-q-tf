# Instances
resource "aws_instance" "primary" {
  ami = "ami-03bbe60df80bdccc0"
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group_id ]
  
  user_data = <<EOF
#!/bin/bash -xe
curl https://github.com/${var.github_username}.keys >> /home/ubuntu/.ssh/authorized_keys
EOF

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_instance" "secondary" {
  count = var.more_instance ? 1 : 0
  ami = "ami-03bbe60df80bdccc0"
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group_id ]

  user_data = <<EOF
    #!/bin/bash
    curl https://github.com/simarisu78.keys >> /home/ubuntu/.ssh/authorized_keys
  EOF

  tags = merge(var.tags, {
    Name = "${var.name}-secondary"
  })
}

resource "aws_instance" "tertiary" {
  count = var.more_instance ? 1 : 0
  ami = "ami-03bbe60df80bdccc0"
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [ var.security_group_id ]

  user_data = <<EOF
    #!/bin/bash -xe
    curl https://github.com/simarisu78.keys >> /home/ubuntu/.ssh/authorized_keys
  EOF

  tags = merge(var.tags, {
    Name = "${var.name}-tertiary"
  })
}
