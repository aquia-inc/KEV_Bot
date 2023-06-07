data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"
}


resource "aws_iam_role_policy" "kev_lambda_policy" {
  name = "kev_lambda_policy"
  role = aws_iam_role.kev_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:*"
        Effect   = "Allow"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.kev_lambda.function_name}:*"
        Effect   = "Allow"
      },
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${aws_dynamodb_table.basic-dynamodb-table.name}"
        Effect   = "Allow"

      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:${local.region}:${local.account_id}:parameter/twitter_*",
          aws_ssm_parameter.slack_webhook_url.aws_region
        ]
      },
      {
        Effect   = "Allow"
        Action   = "ssm:DescribeParameters"
        Resource = "*"
      }
    ]
  })
}


data "aws_iam_policy_document" "kev_lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "kev_lambda_role" {
  name = "kev_lambda_role"

  assume_role_policy = data.aws_iam_policy_document.kev_lambda_trust.json
}