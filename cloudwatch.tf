
resource "aws_cloudwatch_event_rule" "kev_rate" {
  name                = "every-two-hours"
  description         = "launches kev_lambda every two hours"
  schedule_expression = "rate(2 hours)"
}

resource "aws_cloudwatch_event_target" "check_kev" {
  rule      = aws_cloudwatch_event_rule.kev_rate.name
  target_id = aws_lambda_function.kev_lambda.function_name
  arn       = aws_lambda_function.kev_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_kev_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kev_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.kev_rate.arn
}