resource "aws_sqs_queue" "evaluation_service" {

  name = local.queue_name

  delay_seconds = 0

  visibility_timeout_seconds = 30

  message_retention_seconds = 345600

  receive_wait_time_seconds = 10

  sqs_managed_sse_enabled = true

  tags = merge(

    local.common_tags,

    {

      Name = local.queue_name

    }
  )
}
