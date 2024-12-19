provider "aws" {
  region     = "us-east-1"
}

# The general syntax for a Terraform resource is:
#  resource "PROVIDER_TYPE" "NAME" {
#  [CONFIG ...]
#  }



# resource "aws_instance" "example" {
#   ami = "ami-0fb653ca2d3203ac1"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.instance.id]
#   user_data = <<-EOF
#               #!/bin/bas
#               echo "Hello, world" > index.html
#               nohup busybox httpd -f -p 8080 & 
#               EOF

#   tags = {
#     Name = "terraform-example"
#   }
# }

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
data "aws_availability_zones" "available" {}
# resource "aws_default_vpc" "default" {}

# resource "aws_subnet" "public_subnets" {
#   vpc_id                  = aws_default_vpc.default.id
#   cidr_block              = "172.31.0.0/24"
#   availability_zone       = data.aws_availability_zones.available.names[0]

#   tags = {
#     Name      = "public_subnet"
#   }
# }

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<html><h1>Welcome to your Apache Web Server</h1></html>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Webserver EC2 instance"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
  from_port     = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

