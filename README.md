```markdown
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
```

### `main.tf`

This file defines the EC2 instance resource, including its AMI, instance type, and a basic security group.

```terraform
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
```

---

## 🚀 Getting Started

Follow these steps to deploy your EC2 instance using Terraform:

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-directory>
    ```

2.  **Update `main.tf`:**
    * Replace the placeholder `ami` with a valid AMI ID for your desired AWS region. You can find suitable AMIs in the AWS EC2 console or by using the AWS CLI.
    * Replace `"your-key-name"` with the name of an existing SSH key pair in your AWS account. If you don't have one, create it in the EC2 console under "Key Pairs".

3.  **Initialize Terraform:**
    Navigate to the directory containing your `.tf` files and run:
    ```bash
    terraform init
    ```
    This command initializes the working directory and downloads the necessary provider plugins.

4.  **Review the plan:**
    Before applying any changes, it's crucial to review the execution plan. This command shows you what Terraform will create, modify, or destroy.
    ```bash
    terraform plan
    ```
    Carefully examine the output to ensure it matches your expectations.

5.  **Apply the changes:**
    If the plan looks correct, apply the changes to provision the resources in your AWS account.
    ```bash
    terraform apply
    ```
    Terraform will prompt you to confirm the action. Type `yes` and press Enter.

6.  **Access your instance:**
    Once `terraform apply` completes, you will see the `public_ip` and `public_dns` outputs. You can use these to SSH into your instance:
    ```bash
    ssh -i /path/to/your/key.pem ec2-user@<public_ip_from_output>
    ```

---

## 🗑️ Cleaning Up

To destroy the resources created by Terraform (and avoid incurring AWS costs), run:

```bash
terraform destroy
```
Terraform will show you what it's about to destroy and ask for confirmation. Type `yes` and press Enter.

---

## 🤝 Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Suggestions for additional resources or best practices are always welcome!

---

**Happy Terraforming!** 🏗️
```
