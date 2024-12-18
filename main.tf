provider "aws" {
  region     = "us-east-1"
}

# The general syntax for a Terraform resource is:
#  resource "PROVIDER_TYPE" "NAME" {
#  [CONFIG ...]
#  }

resource "aws_instance" "example" {
    ami = "ami-40d28157"
    instance_type = "t2.micro"
    tags = {
      Name = "terraform-example"
  }
}

