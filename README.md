# EC2 Instance Provisioning with Terraform 🚀

This repository contains Terraform configurations to provision an Amazon EC2 (Elastic Compute Cloud) instance. Infrastructure as Code (IaC) with Terraform allows for repeatable, predictable, and version-controlled infrastructure deployments.

---

## ✨ What's Inside?

This setup will provision a single EC2 instance in your AWS account.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed and configured:

* **Terraform:** Download and install Terraform from the [official website](https://www.terraform.io/downloads.html).
* **AWS CLI:** Install and configure the AWS Command Line Interface (CLI) with appropriate credentials. Ensure your AWS credentials have permissions to create EC2 instances, VPC resources (if not using default VPC), and associated security groups.
    * [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

---

## 💻 Terraform Code

Here are the core Terraform files used for provisioning the EC2 instance:

### `provider.tf`

This file defines the AWS provider and the region where your resources will be deployed.

```terraform
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # You can change this to your desired AWS region
}
# Define an AWS EC2 instance
resource "aws_instance" "web_server" {
  # ami = "ami-0abcdef1234567890" # Replace with a valid AMI ID for your region (e.g., Amazon Linux 2 AMI)
  # You can find AMIs in the AWS EC2 console or using AWS CLI:
  # aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --region us-east-1

  # For example, using a common Amazon Linux 2 AMI in us-east-1 (verify current AMI for your region)
  ami           = "ami-053b0d53c279acc90" # Example AMI for Amazon Linux 2 in us-east-1, verify latest
  instance_type = "t2.micro" # Free tier eligible instance type

  # Associate a key pair for SSH access (replace 'your-key-name' with your actual key pair name)
  # You must have this key pair already created in your AWS account.
  key_name = "your-key-name" # <--- IMPORTANT: Replace with your SSH key pair name

  # Define a security group to allow SSH access
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Add tags for better resource organization
  tags = {
    Name        = "MyWebServer"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Define a security group to allow SSH (port 22) access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_from_everywhere"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id # Use the default VPC

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <--- WARNING: Allows SSH from anywhere. Restrict in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_sg"
  }
}

# Data source to get the default VPC ID
data "aws_vpc" "default" {
  default = true
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  description = "The public IP address of the created EC2 instance"
  value       = aws_instance.web_server.public_ip
}

# Output the public DNS of the EC2 instance
output "public_dns" {
  description = "The public DNS name of the created EC2 instance"
  value       = aws_instance.web_server.public_dns
}

## 🚀 Getting Started

Follow these steps to deploy your EC2 instance using Terraform:

1.  **Clone the repository:**
    First, clone this repository to your local machine using Git.
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory> # Navigate into the cloned directory
    ```

2.  **Update `main.tf`:**
    Open the `main.tf` file in your preferred text editor. You **must** modify the following lines:
    * **AMI ID (`ami`):** Replace the placeholder `ami` with a valid AMI ID for your desired AWS region. AMIs are region-specific. You can find suitable AMIs (e.g., for Amazon Linux 2 or Ubuntu) in the AWS EC2 console when launching an instance, or by using the AWS CLI:
        ```bash
        aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId" --region us-east-1
        ```
        (Replace `us-east-1` with your region if different).
    * **Key Pair Name (`key_name`):** Replace `"your-key-name"` with the exact name of an existing SSH key pair in your AWS account. This key is crucial for securely connecting to your EC2 instance via SSH. If you don't have one, you can create it in the EC2 console under "Network & Security" > "Key Pairs".

3.  **Initialize Terraform:**
    Navigate to the directory containing your `.tf` files in your terminal. This command initializes the working directory, downloads the necessary AWS provider plugins, and prepares Terraform for use.
    ```bash
    terraform init
    ```

4.  **Review the plan:**
    Before applying any changes, it is **crucial** to review the execution plan. This command shows you exactly what Terraform intends to create, modify, or destroy in your AWS account without making any actual changes.
    ```bash
    terraform plan
    ```
    Carefully examine the detailed output to ensure it matches your expectations and that no unintended resources will be provisioned.

5.  **Apply the changes:**
    If the `terraform plan` output looks correct and you are ready to provision the resources, apply the changes to your AWS account.
    ```bash
    terraform apply
    ```
    Terraform will once again show you the plan and prompt you to confirm the action. Type `yes` and press Enter to proceed with the provisioning.

6.  **Access your instance:**
    Once `terraform apply` completes successfully, Terraform will output the `public_ip` and `public_dns` of your newly created EC2 instance. You can use these values to connect to your instance via SSH from your local machine.
    ```bash
    ssh -i /path/to/your/key.pem ec2-user@<public_ip_from_output>
    ```
    Replace `/path/to/your/key.pem` with the actual path to your SSH private key file and `<public_ip_from_output>` with the IP address provided by Terraform.

---

## 🗑️ Cleaning Up

To destroy all the AWS resources provisioned by this Terraform configuration (and avoid incurring unnecessary AWS costs), run the following command from the same directory:

```bash
terraform destroy

