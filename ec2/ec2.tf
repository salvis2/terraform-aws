# Launch small machine with Ubunutu 18.04
provider "aws" {
  profile    = "default"
  region     = var.region
}

# Create a new AWS Instance (default VPC)
resource "aws_instance" "salvis-machine" {
  ami           = var.amis[var.region]
  instance_type = var.instance
  tags = {
    Name = "sebastian test machine"
  }
}


