variable "name" {
  description = "name of this resource"
  type = string
}

variable "instance_type" {
  description = "The type of instance to launch"
  type = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
  type = string
}

variable "instance_count" {
  description = "The number of instances to launch"
  type = number
  default = 1
}

variable "max_price" {
  description = "The maximum price you are willing to pay for Spot Instances"
  type = string
}

variable "github_username" {
  description = "The GitHub username to fetch the public key from"
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
}