data "terraform_remote_state" "common_resource" {
  backend = "s3"

  config = {
    bucket = "kyosu-common-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["${data.terraform_remote_state.common_resource.outputs.github_actions_oidc_arn}"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:hackathon-22-digicon-team4/comiQ-UI:*"
      ]
    }
  }
}

resource "aws_iam_policy" "deploy" {
  name = "comiq-frontend.deploy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "s3",
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "${var.s3_arn}",
          "${var.s3_arn}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role" "github_actions" {
  name = "comiq-frontend-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.deploy.arn,
  ]
}