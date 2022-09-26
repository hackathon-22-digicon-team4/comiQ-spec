# 1. ECSクラスタを作成
resource "aws_ecs_cluster" "main" {
  name = "${var.project}_${var.stage}_cluster"
}


# 2. ECSサービスを作成
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project}_${var.stage}_service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_def.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = [var.public_1a.id, var.public_1c.id]
    security_groups  = [var.sg_for_ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.tg.arn
    container_name   = var.project
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }
}

# 3. 各サービス用にタスク定義を作成
resource "aws_ecs_task_definition" "ecs_def" {
  family                   = "${var.project}_${var.stage}_task_definition"
  execution_role_arn       = var.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512" # Linuxが使える最低限

  container_definitions = jsonencode([
    {
      name  = var.project
      image = var.ecr_repo_uri
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.project}_${var.stage}_log_group"
          awslogs-region        = var.region
          awslogs-stream-prefix = var.project
        }
      }
      secrets = [
        {
          "name" : "JSON_FROM_SECRET_MANAGER_STR",
          "valueFrom" : var.env_secret_manager.arn
        },
      ]
    }
  ])
}

# CloudWatch定義
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.project}_${var.stage}_log_group"
  retention_in_days = 30
}
