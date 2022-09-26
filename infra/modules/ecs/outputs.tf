output "cluster" { value = aws_ecs_cluster.main }
output "ecs_service" { value = aws_ecs_service.ecs_service }
output "django_log_group" { value = aws_cloudwatch_log_group.log_group }