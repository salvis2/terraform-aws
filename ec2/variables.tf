variable "region" {
  default = "us-west-2"
}

variable "instance" {
  default = "t2.micro"
}

variable "amis" {
  type = map
  default = {
    "us-east-1" = "ami-00a208c7cdba991ea"
    "us-west-2" = "ami-0a7d051a1c4b54f65"
  }
}
