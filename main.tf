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



resource "aws_s3_bucket" "example" {

  bucket = "Veerteraforrmproject"

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

  user_data = base64encode(file("userdat.sh"))



}

resource "aws_instance" "webserver2" {

  ami                     = "ami-04cdc91e49cb06165"

  instance_type           = "t3.micro"

  subnet_id = aws_subnet.Subnet2.id

  vpc_security_group_ids = [aws_security_group.websg.id]

  user_data = base64encode(file("userdat.sh"))



}





resource "aws_lb" "Myalb" {

  name               = "Myalb"

  internal           = false

  load_balancer_type = "application"

  security_groups    = [aws_security_group.websg.id]

  subnets            = [aws_subnet.Subnet1.id,aws_subnet.Subnet2.id]

  enable_deletion_protection = true

}



resource "aws_lb_target_group" "Mytg" {

  name     = "Mytg"

  port     = 80

  protocol = "HTTP"

  vpc_id   = aws_vpc.My_teraform_vpc.id



  health_check {

    path = "/"

    port = "traffic-port"

  }

}



resource "aws_lb_target_group_attachment" "attach1" {

  target_group_arn = aws_lb_target_group.Mytg.arn

  target_id        = aws_instance.webserver1.id

  port             = 80

}

resource "aws_lb_target_group_attachment" "attach2" {

  target_group_arn = aws_lb_target_group.Mytg.arn

  target_id        = aws_instance.webserver2.id

  port             = 80

}





resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.Myalb.arn

  port              = 80

  protocol          = "HTTP"



  default_action {

    target_group_arn = aws_lb_target_group.Mytg.arn

    type             = "forward"

  }

}



output "loadbalancerdns" {

  value = aws_lb.Myalb.dns_name

}
