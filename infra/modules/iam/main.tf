# ECSのタスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project}_${var.stage}_ecs_task_exec_role"
  assume_role_policy = templatefile("${path.module}/json/assume/template.json", {
    service     = "ecs-tasks"
  })
  tags = {
    Name = "${var.project}_${var.stage}_ecs_task_exec_role"
  }
}
resource "aws_iam_policy" "s3_env_file_access" {
  name        = "${var.project}_${var.stage}_s3_env_file_access_policy"
  description = "secret managerにアクセスできるように"

  policy = templatefile("${path.module}/json/env_secret_manager.tpl.json", {
    env_secret_manager_arn     = var.env_secret_manager.arn
  })
  tags = {
    Name = "${var.project}_${var.stage}_env_secret_manager_access"
  }
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "s3_env_file_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_env_file_access.arn
}
