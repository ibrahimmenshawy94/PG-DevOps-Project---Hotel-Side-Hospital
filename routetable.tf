resource "aws_route_table" "hsh_route_table" {

  vpc_id = aws_vpc.hsh_vpc.id



  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.hsh_igw.id

  }



  tags = {

    Name = "hsh_route_table"

  }

}


