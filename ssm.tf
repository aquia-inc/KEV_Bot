resource "aws_ssm_parameter" "slack_webhook_url" {
  name  = "slack_webhook_url"
  type  = "SecureString"
  value = var.slack_webhook_url
}
