variable "profile" {
  default = "default"
}

variable "region" {
  default = "us-west-2"
}

variable "bucket_name" {
  default = "terraform-pangeo-access-state-alvis"
}

variable "dynamo_table_name" {
  default = "terraform-pangeo-access-locks-alvis"
}
