provider "aws" {
  region = var.region
}

resource "aws_security_group" "wordpress_sg" {
  name_prefix  = var.security_group_prefix
  description  = "Security group for WordPress instances that host their own database."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  security_groups = [aws_security_group.wordpress_sg.name]

  user_data = templatefile("${path.module}/user_data.tpl", {
    db_name         = var.db_name
    db_user         = var.db_user
    db_password     = var.db_password
    db_host         = var.db_host
    certbot_email   = var.certbot_email
    certbot_domain  = var.certbot_domain
  })

  tags = {
    Name = var.instance_name
  }
}
