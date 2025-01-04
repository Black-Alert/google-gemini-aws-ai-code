# IAM Role
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      for assumption in var.service_assumptions : {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = assumption.service
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_xray_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}


# Attach predefined policies if any were provided
resource "aws_iam_role_policy_attachment" "predefined_policies" {
  for_each = {
    for idx, service in var.service_assumptions : idx => service.policy_arn
  }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}


# Attach additional policies if any were provided
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = {for policy_arn in var.additional_policies : policy_arn => null}

  role       = aws_iam_role.this.name
  policy_arn = each.key
}

resource "aws_iam_role_policy" "this" {
  name = "${var.role_name}_access_policy_role_${terraform.workspace}"
  role = aws_iam_role.this.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
