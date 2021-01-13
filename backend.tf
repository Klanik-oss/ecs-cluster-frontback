############################################################################################################
# ECS 
############################################################################################################

#--------------------------------------------------------
# Create a ECS Task back
#--------------------------------------------------------
resource "aws_ecs_task_definition" "ecs_task_back" {
  family                   = "task-back-${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.back_CPU
  memory                   = var.back_MEMORY
  execution_role_arn       = aws_iam_role.R_ecs_execution.arn
  #task_role_arn            = 
  container_definitions    = <<DEFINITION
[
  {
    "image": "${var.back_container_image}",
    "cpu": 256,
    "memory": 512,
    "entryPoint": ["/usr/src/app/app.sh"],
    "name": "${local.back_container_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.back_container_port},
        "hostPort": ${var.back_container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cw_back.name}",
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

#--------------------------------------------------------
# Create Cloudwatch group
#--------------------------------------------------------

resource "aws_cloudwatch_log_group" "cw_back" {
  name = "/fargate/service/backend_${var.app_name}_${var.environment}"
  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

#--------------------------------------------------------
# Create a ECS Service back
#--------------------------------------------------------

resource "aws_ecs_service" "ecs_service_back" {
  name            = "service-back-${var.app_name}-${var.environment}"
  cluster         = aws_ecs_cluster.app_ecs.id
  task_definition = aws_ecs_task_definition.ecs_task_back.arn
  desired_count   = 2
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = aws_alb_target_group.alb_tg_back.arn
    container_name   = local.back_container_name
    container_port   = var.back_container_port
  }
  network_configuration {
    security_groups = [aws_security_group.sg_back.id]
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

resource "aws_security_group" "sg_back" {
  name        = "sgrp-back-${var.app_name}-${var.environment}"
  description = "allow http access to fargate tasks"
  vpc_id      = module.vpc.vpc_id

  depends_on = [aws_alb.alb_back]

  ingress {
    protocol        = "tcp"
    from_port       = var.back_container_port
    to_port         = var.back_container_port
    security_groups = [aws_security_group.sg_alb_back.id] 
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
# Create Application Load Balancer for the backend container
#--------------------------------------------------------

# Create the ALB
resource "aws_alb" "alb_back" {
  name               = "alb-back-${var.app_name}-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  subnets            = module.vpc.private_subnets
  security_groups    = [aws_security_group.sg_alb_back.id]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}


# Create a security group to associate with this ALB
resource "aws_security_group" "sg_alb_back" {
  name        = "sgrp-alb-back-${var.app_name}-${var.environment}"
  description = "controls access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = var.back_container_port
    to_port     = var.back_container_port
    security_groups = [aws_security_group.sg_front.id]
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
resource "aws_alb_target_group" "alb_tg_back" {
  name        = "tg-back-${var.app_name}-${var.environment}"
  port        = var.back_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on  = [aws_alb.alb_back]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

# Create a listener for the ALB
resource "aws_alb_listener" "alb_listener_back" {
  load_balancer_arn = aws_alb.alb_back.id
  port              = var.back_container_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg_back.id
    type             = "forward"
  }
}
