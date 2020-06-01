output "ad_writer_instance_profile_name" {
  description = "the name of the IAM instance profile that has write permissions to the AD"
  value       = aws_iam_instance_profile.adwriter.name
}

output "ad_aws_ssm_document_name" {
  description = "The SSM document name that can then be associated with instances that support that"
  value       = aws_ssm_document.ssm_doc.name
}

output "AdminPassword" {
  description = "The Admin password for the AD"
  value       = random_string.AdminPassword.result
}

output "vpc_id" {
  description = "The VPC AD of the AD"
  value       = aws_vpc.vpc.id
}

output "ad_ips" {
  description = "The IP Addresses of the AD service"
  value       = aws_directory_service_directory.ad.dns_ip_addresses
}

output "subnets" {
  description = "The subnet ids"
  value       = aws_subnet.subnets.*.id
}

output "cidr_block" {
  description = "VPC CIDR block"
  value       = var.cidr_block
}

