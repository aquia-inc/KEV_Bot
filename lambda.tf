
locals {
  lambda_zip_location = "outputs/kev_lambda.zip"
}


resource "null_resource" "install_requests" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "pip install requests 'urllib3<2' -t ${path.module}/imports/requests/python"
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


resource "aws_lambda_layer_version" "requests_layer" {
  filename            = data.archive_file.requests_zip.output_path
  layer_name          = "Requests-KEV-IAC"
  compatible_runtimes = ["python3.10"]
  source_code_hash    = data.archive_file.requests_zip.output_base64sha256
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
  layers           = [aws_lambda_layer_version.requests_layer.arn]
  runtime          = "python3.10"
  source_code_hash = data.archive_file.kev_lambda_zip.output_base64sha256
}
