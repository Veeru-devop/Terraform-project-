resource "aws_vpc" "My_teraform_vpc" {

  cidr_block = var.cidr

}



resource "aws_subnet" "Subnet1" {

  vpc_id     = aws_vpc.My_teraform_vpc.id

  cidr_block = "10.0.0.0/24"

  availability_zone = "eu-north-1a"

  map_public_ip_on_launch = true

}



resource "aws_subnet" "Subnet2" {

  vpc_id     = aws_vpc.My_teraform_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "eu-north-1b"

  map_public_ip_on_launch = true

}



resource "aws_internet_gateway" "mygateway" {

  vpc_id = aws_vpc.My_teraform_vpc.id

}



resource "aws_route_table" "RT" {

    vpc_id = aws_vpc.My_teraform_vpc.id

    route {

        cidr_block = "0.0.0.0/0"

        gateway_id = aws_internet_gateway.mygateway.id

  }

}

resource "aws_route_table_association" "RT1" {

    subnet_id = aws_subnet.Subnet1.id

    route_table_id = aws_route_table.RT.id

}

resource "aws_route_table_association" "RT2" {

    subnet_id = aws_subnet.Subnet2.id

    route_table_id = aws_route_table.RT.id

}



resource "aws_security_group" "websg" {

  name        = "allow_tls"

  description = "Allow TLS inbound traffic and all outbound traffic"

  vpc_id      = aws_vpc.My_teraform_vpc.id



}




resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {

  security_group_id = aws_security_group.websg.id

  cidr_ipv4         = "0.0.0.0/0"

  from_port         = 80

  ip_protocol       = "TCP"

  to_port           = 80

}



resource "aws_security_group_rule" "allow_all_outbound" {

  type        = "egress"

  from_port   = 0

  to_port     = 0

  protocol    = "-1" # -1 means all protocols

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.websg.id

}



resource "aws_instance" "webserver1" {

  ami                     = "ami-04cdc91e49cb06165"

  instance_type           = "t3.micro"

  subnet_id = aws_subnet.Subnet1.id

  vpc_security_group_ids = [aws_security_group.websg.id]

}

resource "aws_instance" "webserver2" {

  ami                     = "ami-04cdc91e49cb06165"

  instance_type           = "t3.micro"

  subnet_id = aws_subnet.Subnet2.id

  vpc_security_group_ids = [aws_security_group.websg.id]

  user_data = base64encode(file("userdat.sh"))



}

