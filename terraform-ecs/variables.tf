variable "image_tag" {
  description = "The tag of the Docker image to deploy."
  default     = "latest"
}
variable "app_name" {
  default = "nordhealth-flask-aws-terraform"
}

variable "container_port" {
  default = 8080
}