# 3つのsgを作成。ALB用、ECS用、RDS用。

# ALB用のsg。インターネットからの80, 443のみ通す。
resource "aws_security_group" "for_alb" {
  name        = "${var.project}_${var.stage}_sg_for_alb"
  description = "allow request 80 and 443 port"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_${var.stage}_sg_alb"
  }
}

# ECSのインスタンス用のsg。ALB用のsgから来た80番ポートへのリクエストのみ通す。
resource "aws_security_group" "for_ecs" {
  name        = "${var.project}_${var.stage}_sg_for_ecs_instance"
  description = "allow request only from alb sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.for_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_${var.stage}_sg_ecs"
  }
}

# DB用のsg。prod&stgのECS用のsgから来た5432番ポートへのリクエストのみ通す。
resource "aws_security_group" "for_rds" {
  name        = "${var.project}_${var.stage}_sg_for_db_instance"
  description = "allow request only from ecs sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.for_ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_${var.stage}_sg_rds"
  }
}

# SSH用のsg。22番ポートへのアクセスを許す
resource "aws_security_group" "for_ssh" {
  name        = "${var.project}_${var.stage}_sg_for_ssh"
  description = "allow ssh request"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_${var.stage}_sg_ssh"
  }
}