output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "bastion_ami_id" {
  description = "AMI ID used for the bastion host"
  value       = data.aws_ami.ubuntu.id
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i your-key.pem ubuntu@${aws_eip.bastion.public_ip}"
}

output "bastion_instance_state" {
  description = "State of the bastion instance"
  value       = aws_instance.bastion.instance_state
}

output "bastion_availability_zone" {
  description = "Availability zone of the bastion host"
  value       = aws_instance.bastion.availability_zone
}