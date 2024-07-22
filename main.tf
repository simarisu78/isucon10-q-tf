# teamごとのサーバー
module "competitives" {
  count  = local.team_counts
  source = "./modules/competitive"

  name          = "isucon-${count.index + 1}"
  instance_type = local.competitive_instance_type
  more_instance = false

  subnet_id         = module.vpc.private_subnets[0]
  security_group_id = module.competitive_security_sg.security_group_id

  github_username = local.github_username

  tags = local.tags
}

module "competitive_security_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "competitive-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

# ベンチマーカー
module "benchmarker" {
  source = "./modules/benchmarker"

  name          = "isucon-benchmarker"
  instance_type = local.benchmarker_instance_type

  subnet_id         = module.vpc.public_subnets[0]
  security_group_id = module.benchmarker_security_sg.security_group_id

  instance_count = local.benchmarker_instance_count
  max_price      = local.benchmarker_max_price

  github_username = local.github_username

  tags = local.tags
}

module "benchmarker_security_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "benchmarker-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 20340
      to_port     = 20340
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
}

# 踏み台用サーバー
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.bastion_instance_type

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.bastion_sg.security_group_id]

  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
curl https://github.com/${local.github_username}.keys >> /home/ubuntu/.ssh/authorized_keys

/bin/sed -i -e "s/#Port 22/Port 20340/" /etc/ssh/sshd_config
systemctl restart sshd
  EOF

  tags = merge(local.tags, {
    Name = "isucon-bastion"
  })
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 20340
      to_port     = 20340
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
}


# ベンチマーカージョブ用 FIFO SQS
resource "aws_sqs_queue" "bench_queue" {
  name = "isucon-bench-queue.fifo"

  fifo_queue                  = true
  content_based_deduplication = true

  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 300

  tags = local.tags
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "isucon"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}