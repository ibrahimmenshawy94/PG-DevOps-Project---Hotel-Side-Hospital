resource "aws_route_table_association" "hsh_rta_public_subnet" {

  subnet_id      = aws_subnet.hsh_public_subnet.id

  route_table_id = aws_route_table.hsh_route_table.id

}


