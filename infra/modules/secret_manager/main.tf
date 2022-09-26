resource "aws_secretsmanager_secret" "env_secret_manager" {
  name        = var.name
  description = "comiQのサーバー用のシークレット"
}

resource "aws_secretsmanager_secret_version" "env_secret_manager_version" {
  secret_id     = aws_secretsmanager_secret.env_secret_manager.id
  secret_string = jsonencode(var.rds_credential)
}