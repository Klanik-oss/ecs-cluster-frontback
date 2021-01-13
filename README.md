## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | Name of the application to deploy | `string` | `"MyApp"` | no |
| availability\_zones | array of aws availability zones of the provided region used by VPC creation | `list(string)` | <pre>[<br>  "eu-west-3a",<br>  "eu-west-3b"<br>]</pre> | no |
| back\_CPU | CPU Required | `string` | `"256"` | no |
| back\_MEMORY | Memory Required | `string` | `"512"` | no |
| back\_container\_image | Image of the backend container | `string` | n/a | yes |
| back\_container\_port | the port that the server serves from | `string` | `"5000"` | no |
| cidr | cidr | `string` | `"10.0.0.0/16"` | no |
| environment | Name of the current environment | `string` | `"no-env"` | no |
| front\_CPU | CPU Required | `string` | `"256"` | no |
| front\_MEMORY | Memory Required | `string` | `"512"` | no |
| front\_container\_image | Image of the frontend container | `string` | n/a | yes |
| front\_container\_port | the port that the server serves from | `string` | `"5000"` | no |
| owner | Owner name or contact | `string` | n/a | yes |
| private\_subnets | array of aws availability zones of the provided region used by VPC creation | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24"<br>]</pre> | no |
| public\_subnets | array of aws availability zones of the provided region used by VPC creation | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24"<br>]</pre> | no |
| region | n aws region | `string` | `"eu-west-3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_back | the DNS name of the backend load balancer |
| alb\_front | the DNS name of the frontend load balancer |

Generated with : terraform-docs markdown modules/ecs-cluster > modules/ecs-cluster/README.md