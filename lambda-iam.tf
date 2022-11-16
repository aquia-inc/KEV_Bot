data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region ="us-east-1"
  my_function = "iac_test"
  db_table_name = "OldKevs"
  
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  
  policy = jsonencode({
    Version = "2012-10-17" 
    Statement = [   
      {   
        Action= "logs:CreateLogGroup"           
        Resource= "arn:aws:logs:${local.region}:${local.account_id}:*"   
        Effect= "Allow"   
      },  
      {   
        Action= [          
          "logs:CreateLogStream",   
          "logs:PutLogEvents"   
        ],   
        Resource= "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${local.my_function}:*"   
        Effect= "Allow"   
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
        Resource = "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${local.db_table_name}"
        Effect = "Allow"

      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/twitter_*"
      },
      {
        Effect = "Allow"
        Action = "ssm:DescribeParameters"
        Resource = "*"
      }




    ]   
})
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = "${file("iam/lambda-assume-policy.json")}"
}