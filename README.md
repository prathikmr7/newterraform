
# EC2 Instance Provisioning with Terraform 🚀

This repository provides Terraform configurations designed to provision a single Amazon EC2 (Elastic Compute Cloud) instance. Leveraging Infrastructure as Code (IaC) principles, this setup ensures that your infrastructure deployments are repeatable, predictable, and fully version-controlled, facilitating seamless collaboration and consistent environments.

---

## ✨ What's Inside?

At its core, this repository contains the necessary Terraform files to define and deploy a single EC2 instance within your Amazon Web Services (AWS) account. It includes configurations for the AWS provider, the EC2 instance itself, and a basic security group to allow SSH access.

---

## 📋 Prerequisites

Before you begin the deployment process, please ensure you have the following tools installed and configured on your local machine:

### Terraform
This is the primary tool for managing your infrastructure. You can download and install the latest version directly from the [official Terraform website](https://www.terraform.io/downloads.html).

### AWS CLI
The AWS CLI is essential for interacting with your AWS account. Make sure it's installed and configured with appropriate credentials that have the necessary permissions to create EC2 instances, manage VPC resources (if you're not using the default VPC), and establish associated security groups. For guidance on setup, refer to the [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

---

## 💻 Terraform Code

The core of this project lies in these Terraform configuration files. They define the desired state of your EC2 instance and its related networking components.

### `provider.tf`

This file specifies the cloud provider (AWS, in this case) and the geographical region where your AWS resources will be deployed. It's the entry point for configuring your cloud environment.

```terraform
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your desired AWS region
}
```

### `main.tf`

This is where the EC2 instance itself is defined. It includes details such as the Amazon Machine Image (AMI) to use, the instance type (e.g., `t2.micro` for free tier eligibility), an SSH key pair for access, and a security group to control inbound and outbound traffic.

```terraform
# Define an AWS EC2 instance
resource "aws_instance" "web_server" {
  # ami = "ami-0abcdef1234567890" # Replace with a valid AMI ID for your region (e.g., Amazon Linux 2 AMI)
  # You can find valid AMIs in the AWS EC2 console or using the AWS CLI command below:
  # aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --region us-east-1

  # Example AMI for Amazon Linux 2 in us-east-1 (please verify the latest AMI for your specific region)
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro" # This is a free tier eligible instance type

  # Associate a key pair for SSH access.
  # IMPORTANT: Replace 'your-key-name' with the actual name of your SSH key pair
  # You must have this key pair already created in your AWS account.
  key_name = "your-key-name"

  # Attach the security group defined below to this EC2 instance
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Apply tags for better resource organization and management
  tags = {
    Name        = "MyWebServer"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Define a security group to allow SSH (port 22) access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH inbound traffic to the EC2 instance"
  vpc_id      = data.aws_vpc.default.id # Automatically use the default VPC for simplicity

  # Ingress rule for SSH traffic
  ingress {
    description = "SSH from any IP address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: This allows SSH from anywhere. Restrict this in production environments!
  }

  # Egress rule to allow all outbound traffic from the instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Represents all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to any IP address
  }

  tags = {
    Name = "allow_ssh_sg"
  }
}

# Data source to retrieve the ID of the default VPC in your AWS account
data "aws_vpc" "default" {
  default = true
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  description = "The public IP address of the created EC2 instance"
  value       = aws_instance.web_server.public_ip
}

# Output the public DNS name of the created EC2 instance
output "public_dns" {
  description = "The public DNS name of the created EC2 instance"
  value       = aws_instance.web_server.public_dns
}
```

---

## 🚀 Getting Started: Deploy Your EC2 Instance

Follow these straightforward steps to deploy your EC2 instance using the provided Terraform configurations:

### Clone the Repository
Begin by cloning this GitHub repository to your local machine. This will give you access to all the necessary Terraform files.

```bash
git clone <your-repo-url>
cd <your-repo-directory> # Navigate into the cloned directory
```

### Update `main.tf`
Open the `main.tf` file in your preferred text editor. It's crucial to customize two specific parameters:

* **AMI ID (`ami`):** Replace the placeholder AMI ID with a valid Amazon Machine Image ID suitable for your chosen AWS region. You can find the most current and appropriate AMI IDs in the AWS EC2 console when launching an instance, or by using the AWS CLI command provided as a comment within `main.tf`.
* **Key Pair Name (`key_name`):** Replace `"your-key-name"` with the exact name of an existing SSH key pair in your AWS account. This key is vital for securely connecting to your EC2 instance via SSH. If you do not have an existing key pair, create one through the EC2 console under "Network & Security" > "Key Pairs" before proceeding.

### Initialize Terraform
Navigate to the directory containing your `.tf` files in your terminal. Execute the following command to initialize the working directory. This step downloads the necessary AWS provider plugins and prepares Terraform for operations.

```bash
terraform init
```

### Review the Plan
Before making any actual changes to your AWS infrastructure, it is **highly recommended** to review Terraform's execution plan. This command provides a detailed preview of what Terraform intends to create, modify, or destroy.

```bash
terraform plan
```
Carefully examine the output to ensure that the proposed changes align with your expectations and that no unintended resources will be provisioned.

### Apply the Changes
If the `terraform plan` output is satisfactory and you are ready to provision the resources, proceed to apply the changes to your AWS account.

```bash
terraform apply
```
Terraform will display the plan again and prompt for confirmation. Type `yes` and press Enter to approve the provisioning process.

### Access Your Instance
Once `terraform apply` successfully completes, Terraform will output the `public_ip` and `public_dns` of your newly created EC2 instance. You can use these values to establish an SSH connection to your instance from your local machine.

```bash
ssh -i /path/to/your/key.pem ec2-user@<public_ip_from_output>
```
Remember to replace `/path/to/your/key.pem` with the actual path to your SSH private key file and `<public_ip_from_output>` with the public IP address provided in the Terraform output.

---

## 🗑️ Cleaning Up: Destroying Resources

To avoid incurring unnecessary AWS costs, it's good practice to destroy resources when they are no longer needed. You can remove all the AWS resources provisioned by this Terraform configuration by running the following command from the same directory:


```bash
terraform destroy
```
Terraform will display a plan of the resources it is about to destroy and ask for your confirmation. Type `yes` and press Enter to confirm the deletion of all managed resources.
