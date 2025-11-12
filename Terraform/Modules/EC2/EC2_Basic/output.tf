# --------------------------------------------------------
# Output - Display AMI ID and Instance Info
# --------------------------------------------------------
output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "instance_public_ip" {
  value = aws_instance.t2_micro_instance.public_ip
}

output "aws_instance_id" {
  value = aws_instance.t2_micro_instance.id
  
}