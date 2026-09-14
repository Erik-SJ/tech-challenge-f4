resource "aws_dynamodb_table" "toggle_master_analytics" {

  name = local.table_name

  billing_mode = "PROVISIONED"

  read_capacity = 1

  write_capacity = 1

  hash_key = "event_id"

  attribute {

    name = "event_id"
    type = "S"

  }

  tags = merge(

    local.common_tags,

    {

      Name = local.table_name

    }
  )
}
