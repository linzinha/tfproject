output "state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = aws_s3_bucket.tf_state.id
}

output "github_plan_role_arn" {
  description = "ARN of the GitHub Actions plan role"
  value       = aws_iam_role.github_plan.arn
}

output "github_apply_role_arn" {
  description = "ARN of the GitHub Actions apply role"
  value       = aws_iam_role.github_apply.arn
}
