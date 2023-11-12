resource "aws_internet_gateway" "hsh_igw" {

  vpc_id = aws_vpc.hsh_vpc.id



  tags = {

    Name = "hsh_igw"

  }

}


