##############################################
# COMPUTE (EC2) MODULE
##############################################

# Amazon Linux 2023 AMI (x86_64 architecture)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64-gp3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# IAM ROLE + INSTANCE PROFILE
resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.name_prefix}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 INSTANCE
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, 0)
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name        = "${var.name_prefix}-server"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
