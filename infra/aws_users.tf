resource "aws_iam_user" "this" {
  name = "black-alert-demo-repo-user-${terraform.workspace}"
  path = "/"

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "admin_attachment" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}