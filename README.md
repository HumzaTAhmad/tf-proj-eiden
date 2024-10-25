## Prerequisites

- Terraform installed
- AWS credentials configured (either through environment variables or AWS CLI)

# Terraform AWS Setup

This repository contains a Terraform configuration to set up an AWS Auto Scaling group with EC2 instances using a launch template and security group configurations.

## Prerequisites

1. **Create AWS Resources**
   - Create a VPC with at least **two private subnets** in the desired AWS region.
   - Create an **IAM role** with an EC2 instance profile and attach any necessary permissions for your setup.
     
2. **AWS credentials configured (either through environment variables or AWS CLI)**
   
3. **Terraform Installed**

4. **Update the `.tfvars` File**
   - Fill in your VPC ID, subnet IDs, AMI ID, and IAM role name in the `terraform.tfvars` file (or define these as environment variables).

## Usage

Once you’ve set up your resources and updated the `.tfvars` file, run the following commands to deploy:

```bash
terraform init
terraform plan
terraform apply
