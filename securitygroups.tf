resource "aws_security_group" "hsh_sg" {

  name        = "hsh_security_group"

  description = "Security group for HSH project"

  vpc_id      = aws_vpc.hsh_vpc.id



  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }



  tags = {

    Name = "hsh_security_group"

  }

}


