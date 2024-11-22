resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
