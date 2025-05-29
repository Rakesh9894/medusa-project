provider "aws" {
  region = var.aws_region
}

# Fetch available availability zones
data "aws_availability_zones" "available" {}

# Create a VPC
resource "aws_vpc" "medusa_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true   # ✅ Enable DNS resolution
  enable_dns_hostnames = true   # ✅ Enable DNS hostnames

  tags = {
    Name = "medusa-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.medusa_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.medusa_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.medusa_vpc.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.medusa_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Database Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "medusa-db-subnet-group"
  subnet_ids = aws_subnet.public_subnets[*].id
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow HTTP traffic to Medusa"
  vpc_id      = aws_vpc.medusa_vpc.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "medusa_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.17"
  instance_class       = "db.t3.micro"
  username             = var.db_user
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
}

# ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# ECS Task Definition for Medusa Backend
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "medusa",
    image     = var.medusa_image,  # Now using Docker Hub
    essential = true,
    portMappings = [{
      containerPort = 9000,
      hostPort      = 9000
    }],
    environment = [
      {
        name  = "DATABASE_URL",
        value = "postgres://${var.db_user}:${var.db_password}@${aws_db_instance.medusa_db.address}:5432/postgres"

      },
      {
        name  = "JWT_SECRET",
        value = var.jwt_secret
      }
    ]
  }])
}

# ECS Fargate Service
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public_subnets[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_internet_gateway.igw]
}
