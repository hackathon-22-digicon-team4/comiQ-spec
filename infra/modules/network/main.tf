resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block_vpc

  tags = {
    Name = "${var.project}_${var.stage}_vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_block_public_1a
  availability_zone       = var.az_1a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}_${var.stage}_public_1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_block_public_1c
  availability_zone       = var.az_1c
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}_${var.stage}_public_1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_block_private_1a
  availability_zone = var.az_1a

  tags = {
    Name = "${var.project}_${var.stage}_private_1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_block_private_1c
  availability_zone = var.az_1c

  tags = {
    Name = "${var.project}_${var.stage}_private_1c"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}_${var.stage}_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}_${var.stage}_rt"
  }
}

resource "aws_route_table_association" "rt_association_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rt_association_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.route_table.id
}
