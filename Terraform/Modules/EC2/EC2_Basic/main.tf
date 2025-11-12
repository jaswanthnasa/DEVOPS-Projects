# --------------------------------------------------------
# Provider Configuration
# --------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}


# --------------------------------------------------------
# Data Source - Fetch Latest Amazon Linux 2 AMI
# --------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]  # Official Amazon AMIs
}

# --------------------------------------------------------
# EC2 Instance - Using the Latest AMI
# --------------------------------------------------------
resource "aws_instance" "t2_micro_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name        = "AmazonLinux2-T2Micro"
    Environment = "Demo"
  }
}

