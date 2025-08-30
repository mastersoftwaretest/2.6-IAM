data "aws_vpc" "selected" {
 filter {
   name   = "tag:Name"
   values = ["shared-vpc"] # to be replaced with your VPC name
 }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["shared-vpc-public-us-east-1a"]
  }
}