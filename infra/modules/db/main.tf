# 1. Auroraが動けるエリアを作成
resource "aws_db_subnet_group" "it_aurora_db_common" {
  name       = "${var.project}_db_subnet_group"
  subnet_ids = [var.private_sub_1a.id, var.private_sub_1c.id]
}

# 2. Auroraクラスタ`aws_rds_cluster`の作成
resource "aws_rds_cluster" "prod" {
  cluster_identifier                  = "comiq-prod"
  engine_mode                         = "provisioned"
  engine                              = "aurora-mysql"
  engine_version                      = "8.0"
  database_name                       = "comiq_prod"
  port                                = 3306
  master_username                     = "admin"
  master_password                     = "auroraDBpassword" # 後ほど変更する
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.it_aurora_db_common.name
  vpc_security_group_ids              = [var.sg_for_rds.id]
  iam_database_authentication_enabled = false

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }

  apply_immediately = true
}

# 3. Auroraインスタンスの作成
resource "aws_rds_cluster_instance" "it_aurora_db_common" {
  cluster_identifier = aws_rds_cluster.prod.id
  identifier         = "${var.project}-serverless-instance"

  engine               = aws_rds_cluster.prod.engine
  engine_version       = aws_rds_cluster.prod.engine_version
  instance_class       = "db.serverless"
  db_subnet_group_name = aws_db_subnet_group.it_aurora_db_common.name

  publicly_accessible = false
}