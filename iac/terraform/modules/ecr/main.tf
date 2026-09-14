resource "aws_ecr_repository" "service" {

  for_each = toset(local.repositories)

  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  image_scanning_configuration {

    scan_on_push = true

  }
  encryption_configuration {

    encryption_type = "AES256"

  }

  tags = merge(

    local.common_tags,

    {

      Name = each.value

    }
  )
}
