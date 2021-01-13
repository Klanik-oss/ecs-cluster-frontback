
#-------------------------------------------
# Create permissission for the ECS cluster 
#-------------------------------------------
#Define the policy
data "aws_iam_policy_document" "P_ecs_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#Define the role
resource "aws_iam_role" "R_ecs_execution" {
  name               = "R_ecs_execution_${var.app_name}_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.P_ecs_execution.json

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}

#Attach both
resource "aws_iam_role_policy_attachment" "Acces_execution" {
  role       = aws_iam_role.R_ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
