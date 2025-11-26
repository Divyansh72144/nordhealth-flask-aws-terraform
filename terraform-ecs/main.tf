#fetches and uses the subnets linked with default vpc in my AWS account
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default"  {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

#security group for ecs service
resource "aws_security_group" "ecs_service" {
    name        = "${var.app_name}-sg"
    description = "Allow public and inbound trafic to app"
    vpc_id      = data.aws_vpc.default.id

#incoming traffic
    ingress {
        from_port   = var.container_port
        to_port     = var.container_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

#outgoing traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# creates Container registry 
resource "aws_ecr_repository" "app" {
    name         = var.app_name
    force_delete = true
}

# creates ECS cluster
resource "aws_ecs_cluster" "app" {
    name = var.app_name
}

#IAM role for pulling images
resource "aws_iam_role" "ecs_task_execution" {
    name    = "${var.app_name}-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
         Statement = [{
            Effect = "Allow",
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            },
            Action = "sts:AssumeRole"
    }] 
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Task definition = how to run the container
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
    essential = true
    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]
  }])
}

# ecs service that actually runs the container
resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  launch_type     = "FARGATE"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
}
