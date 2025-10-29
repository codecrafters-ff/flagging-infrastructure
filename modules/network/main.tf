##############################################
# NETWORK MODULE
##############################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc", Environment = var.environment }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

# Public Subnet a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_a
  map_public_ip_on_launch = true
  availability_zone       = var.az_a
  tags = { Name = "${var.name}-public-a" }
}

# Public Subnets b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr_b
  map_public_ip_on_launch = true
  availability_zone       = var.az_b
  tags = { Name = "${var.name}-public-b" }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name}-public-rt" }
}

# Route Table Associations a
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations b
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Security group for the EC2 host that will run docker
resource "aws_security_group" "host" {
  name        = "${var.name}-host-sg"
  description = "Allow web/ssh (dev), restrict db/redis to self"
  vpc_id      = aws_vpc.this.id

  # (TEMP) open 8080 for API in dev; will remove later when you add a reverse proxy
  ingress { 
    from_port = 8080 
    to_port = 8080 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
}
  # SSH for emergency; prefer SSM instead
  ingress { 
    from_port = 22 
    to_port = 22 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Web if you expose via nginx later
  ingress { 
    from_port = 80 
    to_port = 80 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { 
    from_port = 443 
    to_port = 443 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress  { 
    from_port = 0
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = { Name = "${var.name}-host-sg" }
}
