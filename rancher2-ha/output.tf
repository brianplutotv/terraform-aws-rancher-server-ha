output "address" {
  value = aws_elb.rancher.dns_name
}

output "instance_ips" {
  value = aws_instance.rancher_node.*.public_ip
}

output "etcd_backup_s3_bucket_id" {
  description = "S3 bucket ID for etcd backups."
  value       = aws_s3_bucket.etcd_backups.id
}

output "etcd_backup_user_key" {
  description = "AWS IAM access key id for etcd backup user."
  value       = aws_iam_access_key.etcd_backup_user.id
  sensitive   = true
}

output "etcd_backup_user_secret" {
  description = "AWS IAM secret access key for etcd backup user."
  value       = aws_iam_access_key.etcd_backup_user.secret
  sensitive   = true
}

output "rancher_admin_password" {
  description = "Password set for Rancher local admin user."
  value       = local.rancher_password
  sensitive   = true
}

output "rancher_token" {
  description = "Admin token for Rancher cluster use"
  value       = rancher2_bootstrap.admin.token
  sensitive   = true
}

output "rancher_api_url" {
  description = "FQDN of Rancher's Kubernetes API endpoint."
  value       = local.api_server_url
}

output "rancher_url" {
  description = "URL at which to reach Rancher."
  value       = rancher2_bootstrap.admin.url
}
