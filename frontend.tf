############################################################################################################
# ECS 
############################################################################################################

#--------------------------------------------------------
# Create a ECS Task front
#--------------------------------------------------------
resource "aws_ecs_task_definition" "ecs_task_front" {
  family                   = "task-front-${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.front_CPU
  memory                   = var.front_MEMORY
  execution_role_arn       = aws_iam_role.R_ecs_execution.arn
  #task_role_arn            = 
  container_definitions    = <<DEFINITION
[
  {
    "image": "${var.front_container_image}",
    "cpu": 256,
    "memory": 512,
    "entryPoint": ["/usr/src/app/app.sh"],
    "name": "${local.front_container_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.front_container_port},
        "hostPort": ${var.front_container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "backend_url",
        "value": "${aws_alb.alb_back.dns_name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cw_front.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

resource "aws_cloudwatch_log_group" "cw_front" {
  name = "/fargate/service/frontend_${var.app_name}_${var.environment}"
  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

#--------------------------------------------------------
# Create a ECS Service front
#--------------------------------------------------------

resource "aws_ecs_service" "ecs_service_front" {
  name            = "service-front-${var.app_name}-${var.environment}"
  cluster         = aws_ecs_cluster.app_ecs.id
  task_definition = aws_ecs_task_definition.ecs_task_front.arn
  desired_count   = 2
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = aws_alb_target_group.alb_tg_front.arn
    container_name   = local.front_container_name
    container_port   = var.front_container_port
  }
  network_configuration {
    security_groups = [aws_security_group.sg_front.id]
    subnets         = module.vpc.private_subnets
  }
  
  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

############################################################################################################
# Network
############################################################################################################


#--------------------------------------------------------
# Create the SG for the ECS tasks
#--------------------------------------------------------

resource "aws_security_group" "sg_front" {
  name        = "sgrp-front-${var.app_name}-${var.environment}"
  description = "allow http access to fargate tasks"
  vpc_id      = module.vpc.vpc_id

  depends_on = [aws_alb.alb_front]

  ingress {
    protocol        = "tcp"
    from_port       = var.front_container_port
    to_port         = var.front_container_port
    security_groups = [aws_security_group.sg_alb_front.id] // not sure why ingress rule gets an array of sec groups
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
    
  }
}

#--------------------------------------------------------
# Create Application Load Balancer for the frontend container
#--------------------------------------------------------

# Create the ALB
resource "aws_alb" "alb_front" {
  name               = "alb-front-${var.app_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.sg_alb_front.id]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

# Create a security group to associate with this ALB
resource "aws_security_group" "sg_alb_front" {
  name        = "sgrp-alb-front-${var.app_name}-${var.environment}"
  description = "controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

# Create the target group to associate with ALB
resource "aws_alb_target_group" "alb_tg_front" {
  name        = "tg-front-${var.app_name}-${var.environment}"
  port        = var.front_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.alb_front]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

# Create a listener for the ALB
resource "aws_alb_listener" "alb_listener_front" {
  load_balancer_arn = aws_alb.alb_front.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg_front.id
    type             = "forward"
  }
}