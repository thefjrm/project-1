terraform {
  required_providers { # Specify the required providers
    aws = {
      source  = "hashicorp/aws" # AWS provider from HashiCorp
      version = "~> 3.0" # Version constraint for the AWS provider
    }
  }
}

# This Terraform configuration file sets up an AWS environment with an EC2 instance, VPC, Internet Gateway, Route Table, Subnet, Route Table Association, Security Group, Network Interface Card and Elastic IP Address.
# It includes the necessary provider configuration and resource definitions.
provider "aws" { # AWS provider configuration
  region = "us-east-1" # Replace with your desired region
  access_key = "my-access-key" # Replace with your actual access key
  secret_key = "my-secret-key" # Replace with your actual secret key
}

# Resource block for an AWS EC2 instance
resource "aws_instance" "web_server" {
  ami = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a" # Availability zone for the instance
  key_name = "my-key-pair" # Replace with your actual key pair name
  network_interface {
    network_interface_id = aws_network_interface.web_server_nic.id # Reference to the network interface created below
    device_index = 0 # Device index for the network interface
  }
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    echo "Hello, World!" > /var/www/html/index.html # Simple user data script to create a web page
    EOF
  tags = {
    Name = "Web Server" # Tag for the EC2 instance
  }
}

# Resource block for an AWS VPC
resource "aws_vpc" "my_vpc" { # Resource block for an AWS VPC
  cidr_block = "10.0.0.0/16" # CIDR block for the VPC
  tags = {
    Name = "prod" # Tag for the VPC
  }
}

# Resource block for an AWS internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id # Reference to the VPC created above
  tags = {
    Name = "prod-igw" # Tag for the internet gateway
  }
}

# Resource block for an AWS route table
resource "aws_route_table" "my_route_table" { # Resource block for an AWS route table
  vpc_id = aws_vpc.my_vpc.id # Reference to the VPC created above
  route {
    cidr_block = "0.0.0.0/0" # Route for all traffic
    gateway_id = aws_internet_gateway.igw.id # Reference to the internet gateway
  }
  tags = {
    Name = "prod-route-table" # Tag for the route table
  }
}

# Variable block for subnet CIDR
variable "subnet_cidr" { # Variable for subnet CIDR block
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24" # Default CIDR block for the subnet
}

# Resource block for an AWS subnet
resource "aws_subnet" "my_subnet" { # Resource block for an AWS subnet
  vpc_id = aws_vpc.my_vpc.id # Reference to the VPC created above
  cidr_block = var.subnet_cidr # CIDR block for the subnet with variable reference
  availability_zone = "us-east-1a" # Availability zone for the subnet
  tags = {
    Name = "prod-subnet" # Tag for the subnet
  }
}

# Resource block for an AWS associate route table
resource "aws_route_table_association" "my_route_table_association" { # Resource block for associating a route table with a subnet
  subnet_id      = aws_subnet.my_subnet.id # Reference to the subnet created above
  route_table_id = aws_route_table.my_route_table.id # Reference to the route table created above
}

# Resource block for an AWS security group
resource "aws_security_group" "my_security_group" { # Resource block for an AWS security group
  name        = "my-security-group" # Name of the security group
  description = "Allow Web inbound traffic" # Description of the security group
  vpc_id      = aws_vpc.my_vpc.id # Reference to the VPC created above
  ingress {
    from_port   = 80 # Allow traffic on port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from any source
  }
  ingress {
    from_port   = 22 # Allow SSH traffic on port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443 # Allow HTTPS traffic on port 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prod-security-group" # Tag for the security group
  }
}

# Resource block for an AWS network interface
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.my_security_group.id]
}

# Resource block for an AWS elastic IP
resource "aws_eip" "one" {
  vpc = true
  network_interface = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.igw ]
}

output "server_public_ip" { # Output the public IP of the EC2 instance
  value = aws_eip.one.public_ip # Reference to the public IP of the elastic IP created above
}

output "server_private_ip" { # Output the private IP of the EC2 instance
  value = aws_instance.web_server.private_ip # Reference to the private IP of the EC2 instance
}
