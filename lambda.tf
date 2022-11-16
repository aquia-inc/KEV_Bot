
locals{
    lambda_zip_location = "outputs/iac_test.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "python.zip"
  layer_name = "Requests-2-28-1-IAC"
  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_layer_version" "lambda_layer_2" {
  filename   = "tweets/python.zip"
  layer_name = "tweepy-4-28-1-IAC"
  compatible_runtimes = ["python3.9"]
}
data "archive_file" "iac_test" {
  type        = "zip"
  source_file = "${path.module}/iac_test.py"
  output_path = "${local.lambda_zip_location}"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${local.lambda_zip_location}"
  function_name = "iac_test"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "iac_test.lambda_handler"
  timeout       = 240
  layers        = [aws_lambda_layer_version.lambda_layer.arn, aws_lambda_layer_version.lambda_layer_2.arn]

  
  # source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.9"

  
}



