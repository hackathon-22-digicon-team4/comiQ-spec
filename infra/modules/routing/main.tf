# 1.ALBを作成
resource "aws_lb" "main" {
  load_balancer_type = "application"
  security_groups    = [var.sg_for_alb.id]
  subnets            = [var.public_1a.id, var.public_1c.id]

  tags = {
    Name = "${var.project}_${var.stage}_alb"
  }
}

# 2. そのALB用に2つのaws_lb_listenerを作る。
# 80番
resource "aws_lb_listener" "redirect_to_https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 443番
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.make_ssl.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

# 3. 443番リスナー用のリスナールールを作る。
resource "aws_lb_listener_rule" "listenr_rule" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  lifecycle {
    ignore_changes = [action]
  }

}

# 4. 443番ポートのリスナーがリクエストを流すターゲットグループを作る
resource "aws_lb_target_group" "tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc.id

  health_check {
    path = "/api/v1/"
  }
  depends_on = [
    aws_lb.main,
  ]
}
