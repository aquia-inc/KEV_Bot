
locals {
  lambda_zip_location = "outputs/kev_lambda.zip"
}

resource "null_resource" "install_requests" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pip install requests -t ${path.module}/imports/requests/python"
  }
}

resource "null_resource" "install_tweepy" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pip install tweepy -t ${path.module}/imports/tweepy/python"
  }
}

data "archive_file" "requests_zip" {
  type        = "zip"
  source_dir  = "${path.module}/imports/requests/"
  output_path = "${path.module}/layers/requests/python.zip"

  depends_on = [
    null_resource.install_requests
  ]
}

data "archive_file" "tweepy_zip" {
  type        = "zip"
  source_dir  = "${path.module}/imports/tweepy/"
  output_path = "${path.module}/layers/tweepy/python.zip"
  depends_on = [
    null_resource.install_tweepy
  ]
}

resource "aws_lambda_layer_version" "requests_layer" {
  filename            = data.archive_file.requests_zip.output_path
  layer_name          = "Requests-KEV-IAC"
  compatible_runtimes = ["python3.9"]
  source_code_hash    = data.archive_file.requests_zip.output_base64sha256

}

resource "aws_lambda_layer_version" "tweepy_layer" {
  filename            = data.archive_file.tweepy_zip.output_path
  layer_name          = "tweepy-KEV-IAC"
  compatible_runtimes = ["python3.9"]
  source_code_hash    = data.archive_file.tweepy_zip.output_base64sha256

}

data "archive_file" "kev_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/kev_lambda.py"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "kev_lambda" {
  filename         = data.archive_file.kev_lambda_zip.output_path
  function_name    = "kev_lambda"
  role             = aws_iam_role.kev_lambda_role.arn
  handler          = "kev_lambda.lambda_handler"
  timeout          = 240
  layers           = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.tweepy_layer.arn]
  runtime          = "python3.9"
  source_code_hash = data.archive_file.kev_lambda_zip.output_base64sha256

}
