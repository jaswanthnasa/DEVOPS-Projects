### How to use this basic module example main.tf

```
module "ec2" {
  source = "git::https://github.com/jaswanthnasa/DEVOPS-Projects.git//Terraform/Modules/EC2/EC2_Basic?ref=v1.0.0"

  instance_type = "t2.micro"
  aws_region    = "ap-south-1"

  
  tag_Name      = "AmazonLinux2-T2Micro-Demo-Instance"
  tag_Environment = "Dev"
}



output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "aws_instance_id" {
  value = module.ec2.aws_instance_id
}
```

#### Alternatively we can keep release version in seperate lcoals.tf file

  ```
  locals {
  vpc_module_version = "v1.0.0"
  vpc_module_source  = "git::https://github.com/org/repo.git?ref=${local.vpc_module_version}"
}

============

module "vpc" {
  source = local.vpc_module_source
}

  ```