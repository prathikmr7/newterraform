# provider "aws" {
#  region = "ap-aouth-1"
#   access_key = ""
#   secret_key = ""
# }

resource "aws_instance" "admin" {
  ami = "ami-0e35ddab05955cf57"
  instance_type = "t2.medium"
  security_groups = ["default"]
  key_name = "windows"
  root_block_device {
    
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name ="Admin-Server"
  }
}

output "Public IP" {
  value = aws_instance.admin.public_ip  
}