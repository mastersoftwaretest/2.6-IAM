locals {
 name_prefix = "jiaqing"
}


resource "aws_iam_role" "role_example" {
 name = "${local.name_prefix}-dynamodb-read-role"


 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "ec2.amazonaws.com"
       }
     },
   ]
 })
}


data "aws_iam_policy_document" "policy_example" {
 statement {
   effect    = "Allow"
   actions   = ["ec2:Describe*"]
   resources = ["*"]
 }
 statement {
   effect    = "Allow"
   actions   = ["dynamodb:ListTables"]
   resources = ["*"]
 }
 statement {
   effect    = "Allow"
   actions   = ["dynamodb:Scan"]
   resources = ["*"]
 }
}


resource "aws_iam_policy" "policy_example" {
 name = "${local.name_prefix}-dynamodb-read"


 ## Option 1: Attach data block policy document
 policy = data.aws_iam_policy_document.policy_example.json


}


resource "aws_iam_role_policy_attachment" "attach_example" {
 role       = aws_iam_role.role_example.name
 policy_arn = aws_iam_policy.policy_example.arn
}


resource "aws_iam_instance_profile" "profile_example" {
 name = "${local.name_prefix}-dynamodb-read-profile"
 role = aws_iam_role.role_example.name
}

resource "aws_dynamodb_table" "bookinventory" {
  name         = "jiaqing-bookinventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ISBN"
  range_key    = "Genre"

  attribute {
    name = "ISBN"
    type = "S"
  }

  attribute {
    name = "Genre"
    type = "S"
  }

}

resource "aws_instance" "public" {
  ami                         = var.ami_id # find the AMI ID of Amazon Linux 2023  
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id #Public Subnet ID, e.g. subnet-xxxxxxxxxxx
  associate_public_ip_address = true
  key_name                    = var.key_name #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile = aws_iam_instance_profile.profile_example.name

  tags = {
    Name = "${var.name}-ec2"    #Prefix your own name, e.g. jazeel-ec2
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.name}-terraform-sg" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.selected.id  #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

