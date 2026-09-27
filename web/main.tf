terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-state-297580067361"
    key    = "tf-layered-infra/network/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www
    echo "Web layer running behind a security group from the network layer" > /var/www/index.html
    cd /var/www
    nohup python3 -m http.server ${data.terraform_remote_state.network.outputs.server_port} &
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "layered-web-server"
  }
}
