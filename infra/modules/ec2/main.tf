resource "aws_instance" "ec2" {
  ami                         = "ami-004332b441f90509b"
  instance_type               = "t4g.nano"
  subnet_id                   = var.public_1a.id
  vpc_security_group_ids      = [var.sg_ec2_alb.id, var.sg_ec2_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project}_${var.stage}_ec2"
  }
}

resource "aws_eip" "eip_manager" {
  instance = aws_instance.ec2.id
  vpc = true

  tags = {
    Name = "${var.project}_${var.stage}_ec2_eip"
  }
}