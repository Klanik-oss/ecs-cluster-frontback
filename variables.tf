variable "region" {
  type        = string
  description = "n aws region"
  default     = "eu-west-3"
}

variable "app_name" {
    type = string
    description = "Name of the application to deploy"
    default = "MyApp"
}

variable "environment" {
    type = string
    description = "Name of the current environment"
    default = "no-env"
}

variable "owner" {
  type        = string
  description = "Owner name or contact"
}

#--------------------------------------------------------
# Network
#--------------------------------------------------------

variable "cidr" {
  type = string
  description = "cidr"
  default = "10.0.0.0/16" 
}

variable "public_subnets" {
  type        = list(string)
  description = "array of aws availability zones of the provided region used by VPC creation"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "array of aws availability zones of the provided region used by VPC creation"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "array of aws availability zones of the provided region used by VPC creation"
  default     = ["eu-west-3a", "eu-west-3b"]
}

#---------------------------
# Frontend container
#---------------------------

variable "front_container_image" {
  type        = string
  description = "Image of the frontend container"
}

variable "front_container_port" {
  type        = string
  description = "the port that the server serves from"
  default = "5000"
}

variable "front_CPU" {
  type = string
  description = "CPU Required"
  default = "256"
  
}

variable "front_MEMORY" {
  type = string
  description = "Memory Required"
  default = "512"
}

#---------------------------
# Backend container
#---------------------------

variable "back_container_image" {
  type        = string
  description = "Image of the backend container"
}

variable "back_container_port" {
  type        = string
  description = "the port that the server serves from"
  default = "5000"
}

variable "back_CPU" {
  type = string
  description = "CPU Required"
  default = "256"
}

variable "back_MEMORY" {
  type = string
  description = "Memory Required"
  default = "512"
}