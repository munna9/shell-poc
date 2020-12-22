#VPC for Application
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main"
  }
}

#Creating IGW 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

#Creating Subnets
resource "aws_subnet" "subnets" {
  count                   = length(var.availability_zone)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnets_cidr,count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "openvpn_subnet-${count.index+1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  count                       = var.instance_count
  subnet_id      = aws_subnet.subnets.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "r" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}