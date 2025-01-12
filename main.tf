/*
    A     B     A     A     S     I
   A A    B B   A A   A A  S       I
  AAAAA   BBB   AAAAA  AAAAA  SSS    I
 A     A  B  B  A   A  A   A     S   I
A     A  B   B A   A A   A SSSS    I

Terraform AWS Infrastructure Deployment
Author: Abaasi
*/
provider "aws" {
  region = "us-east-1"
}

provider "random" {}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform-VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Terraform-Public-Subnet"
  }
}

# Create a second public subnet
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Terraform-Public-Subnet-2"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-IGW"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform-Public-Route-Table"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "terraform-example-bucket-12345-${random_id.bucket_suffix.hex}" # Append a random suffix
}

# Add a random ID resource for the bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Set a bucket policy to make the bucket private
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Create an RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro" # Use a supported instance class
  db_name              = "terraformdb"
  username             = "admin"
  password             = var.rds_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.example.name

  tags = {
    Name = "Terraform-RDS"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "example" {
  name       = "terraform-db-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name = "Terraform-DB-Subnet-Group"
  }
}

# Create a security group for RDS
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-RDS-Security-Group"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}