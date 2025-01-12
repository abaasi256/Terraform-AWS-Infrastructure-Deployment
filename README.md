# Terraform AWS Infrastructure Deployment

This project demonstrates how to use **Terraform** to provision and manage **AWS resources**, including:
- **VPC**: Virtual Private Cloud with subnets, internet gateway, and route tables.
- **S3 Bucket**: Secure S3 bucket with a bucket policy to enforce HTTPS access.
- **RDS Instance**: MySQL database instance with a security group and subnet group across multiple AZs.
- **GitHub Actions**: Automated Terraform workflow for CI/CD.

## Features
- **Infrastructure as Code (IaC)**: Define and manage AWS resources using Terraform.
- **Multi-AZ Deployment**: Ensure high availability for the RDS instance.
- **Secure S3 Bucket**: Enforce HTTPS access and deny public access using bucket policies.
- **Automated Workflow**: Integrate Terraform with GitHub Actions for automated deployments.

## Prerequisites
- **AWS Account**: Ensure you have an AWS account with the necessary permissions.
- **Terraform**: Install Terraform on your local machine.
- **GitHub Repository**: Fork or clone this repository.

## Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/abaasi256/terraform-aws-ec2.git
   cd terraform-aws-ec2

   ## Contributors
- **Abaasi**: Project author and maintainer.