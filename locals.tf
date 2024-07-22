locals {
  team_counts = 1

  # github_username
  github_username = "<your_username>"

  # bastion
  bastion_instance_type = "t3.small"

  # competitive
  competitive_instance_type = "c6i.large"

  # Bench
  benchmarker_instance_type  = "r6i.large"
  benchmarker_instance_count = 1
  benchmarker_max_price      = "0.3"

  tags = {
    Terraform = "true"
    Project   = "isucon10"
  }
}
