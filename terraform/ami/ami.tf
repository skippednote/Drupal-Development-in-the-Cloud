# We will be provisioning AWS infrastructure
provider "aws" {
  region = "ap-south-1"
}

resource "aws_ami_from_instance" "ami" {
  name               = "drupal_vm"
  source_instance_id = "SOURCE_INSTANCE_ID"
}

output "ami" {
  value = aws_ami_from_instance.ami.id
}
