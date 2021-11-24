variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-east-1"
}

variable "DB_USERNAME" {}
variable "DB_PASSWORD" {}

#Select Ubuntu images as per region
variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-083654bd07b5da81d"
    us-east-2 = "ami-0629230e074c580f2"
  }
}
