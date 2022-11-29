resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "OldKevs"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "i"

  attribute {
    name = "i"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }
}