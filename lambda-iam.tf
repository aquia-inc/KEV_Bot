data "aws_caller_identity" "current" {}
locals {
  account_id    = data.aws_caller_identity.current.account_id
  region        = "us-east-1"
  my_function   = "kev_lambda"
  db_table_name = "OldKevs"

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
        Resource = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/twitter_*"
      },
      {
        Effect   = "Allow"
        Action   = "ssm:DescribeParameters"
        Resource = "*"
      }




    ]
  })
}

resource "aws_iam_role" "kev_lambda_role" {
  name = "kev_lambda_role"

  assume_role_policy = file("iam/lambda-assume-policy.json")
}