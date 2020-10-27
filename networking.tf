resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Routes"
  }
}

resource "aws_subnet" "main-subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main-subnet.id
  route_table_id = aws_route_table.main-route-table.id
}

resource "aws_security_group" "security-group" {
  name        = "security-group"
  description = "security-group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Task ports"
    from_port   = 80
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "open-ports"
  }
}

resource "aws_network_interface" "network-1" {
  subnet_id       = aws_subnet.main-subnet.id
  security_groups = [aws_security_group.security-group.id]
  #associate_public_ip_address = true
  private_ips = ["10.0.1.50", "10.0.1.51"]

  tags = {
    Name = "my-network-%132%"
  }
}

resource "aws_network_interface" "network-2" {
  subnet_id       = aws_subnet.main-subnet.id
  security_groups = [aws_security_group.security-group.id]
  private_ips     = ["10.0.1.60"]
  #associate_public_ip_address = true

  tags = {
    Name = "my-network-%132%"
  }
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.network-1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.network-2.id
  associate_with_private_ip = "10.0.1.60"
  depends_on                = [aws_internet_gateway.gw]
}
