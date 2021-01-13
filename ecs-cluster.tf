#--------------------------------------------------------
# Create a ECS cluster
#--------------------------------------------------------

resource "aws_ecs_cluster" "app_ecs" {
  name = "ecs-${var.app_name}-${var.environment}"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

