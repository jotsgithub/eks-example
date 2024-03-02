resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }
}

resource "aws_main_route_table_association" "rt-assoc" {
  route_table_id = aws_route_table.main.id
  vpc_id         = aws_vpc.main.id
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/27"
  tags = {
    Name = "PublicSubnet1"
  }
  availability_zone = data.aws_availability_zones.azs.names[0]
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.32/27"
  tags = {
    Name = "PublicSubnet2"
  }
  availability_zone = data.aws_availability_zones.azs.names[1]
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.128.0/19"
  tags = {
    Name = "PrivateSubnet1"
  }
  availability_zone = aws_subnet.PublicSubnet1.availability_zone
}

resource "aws_subnet" "PrivateSubnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.160.0/19"
  tags = {
    Name = "PrivateSubnet2"
  }
  availability_zone = aws_subnet.PublicSubnet2.availability_zone
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.PublicSubnet1.id
  allocation_id = aws_eip.nat-eip.allocation_id
}

resource "aws_route_table" "rt-private-1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "rt-assoc-private1" {
  route_table_id = aws_route_table.rt-private-1.id
  subnet_id = aws_subnet.PrivateSubnet1.id
}


resource "aws_route_table_association" "rt-assoc-private2" {
  route_table_id = aws_route_table.rt-private-1.id
  subnet_id = aws_subnet.PrivateSubnet2.id
}