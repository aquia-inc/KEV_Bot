
locals {
  lambda_zip_location = "outputs/iac_test.zip"
}

resource "null_resource" "install_requests"{
  provisioner "local-exec" {
    command = "pip install requests -t ${path.module}/imports/requests/python"
      }
}

resource "null_resource" "install_tweepy"{
  provisioner "local-exec" {
    command = "pip install tweepy -t ${path.module}/imports/tweepy/python"
      }
}

data "archive_file" "requests_zip"{
  type = "zip"
  source_dir = "${path.module}/imports/requests/"
  output_path = "${path.module}/layers/requests/python.zip"
  
  depends_on =[
    null_resource.install_requests
  ]
}

data "archive_file" "tweepy_zip"{
  type = "zip"
  source_dir = "${path.module}/imports/tweepy/"
  output_path = "${path.module}/layers/tweepy/python.zip"  
  depends_on =[
    null_resource.install_tweepy
  ]
}

resource "aws_lambda_layer_version" "requests_layer" {
  filename            = data.archive_file.requests_zip.output_path
  layer_name          = "Requests-2-28-1-IAC"
  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_layer_version" "tweepy_layer" {
  filename            = data.archive_file.tweepy_zip.output_path
  layer_name          = "tweepy-4-28-1-IAC"
  compatible_runtimes = ["python3.9"]
}
data "archive_file" "iac_test" {
  type        = "zip"
  source_file = "${path.module}/iac_test.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "test_lambda" {  
  filename      = data.archive_file.iac_test.output_path
  function_name = "iac_test"
  role          = aws_iam_role.lambda_role.arn
  handler       = "iac_test.lambda_handler"
  timeout       = 240
  layers        = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.tweepy_layer.arn]

  runtime = "python3.9"


}



