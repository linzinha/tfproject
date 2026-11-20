resource "aws_iam_role" "github_plan" {
  name               = "github-plan"
  assume_role_policy = data.aws_iam_policy_document.github_plan_trust.json
}

resource "aws_iam_role" "github_apply" {
  name               = "github-apply"
  assume_role_policy = data.aws_iam_policy_document.github_apply_trust.json
}

resource "aws_iam_role_policy_attachment" "github_plan_readonly" {
  role       = aws_iam_role.github_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "github_apply_admin" {
  role       = aws_iam_role.github_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "github_plan_s3" {
  statement {
    sid       = "ReadTerraformState"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::tfproject-state-712069388941/infra/terraform.tfstate"]
  }

  statement {
    sid = "ManageTerraformLock"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::tfproject-state-712069388941/infra/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid       = "ListTerraformState"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::tfproject-state-712069388941"]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "infra/terraform.tfstate",
        "infra/terraform.tfstate.tflock"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_plan_s3" {
  name   = "github-plan-s3"
  role   = aws_iam_role.github_plan.id
  policy = data.aws_iam_policy_document.github_plan_s3.json
}

data "aws_iam_policy_document" "github_plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:linzinha@45407371/tfproject@1464719635:pull_request"]
    }
  }
}

data "aws_iam_policy_document" "github_apply_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:linzinha@45407371/tfproject@1464719635:ref:refs/heads/main"]
    }
  }
}
