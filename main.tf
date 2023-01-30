#---------------Ansible Master----------------------------------
# My terraform
#
# StartUp etst stage
#
#--------------------------------------------------

provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "amazon_server" {
  ami                    = "ami-0cc814d99c59f3789" # Amazon RedHat AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name  = "Amazon test Webserver"
    Owner = "mirexcool"
  }
  key_name = "Ansible-Node-1"
}

resource "aws_eip_association" "amazon_server_eip" {
  instance_id   = aws_instance.amazon_server.id
  allocation_id = "eipalloc-0cea79d42edfef2aa"

}

resource "aws_instance" "ubuntu_server" {
  ami                    = "ami-03b755af568109dc3" # Ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name  = "Ubuntu test Webserver"
    Owner = "mirexcool"
  }
  key_name = "Ansible-Node-2"
}

resource "aws_eip_association" "ubuntu_server_eip" {
  instance_id   = aws_instance.ubuntu_server.id
  allocation_id = "eipalloc-05f6f2df267df28fe"
}

resource "aws_security_group" "web_server_sg" {
  name        = "Web Server Security Group"
  description = "Default SG for Web Server"



  ingress {
    from_port   = 22 #SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 #http port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080 #http port
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "Web Server SG"
    Owner = "mirexcool"
  }

}



#elb
resource "aws_elb" "web" {
  name               = "WebServer-HA-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  security_groups    = [aws_security_group.web_server_sg.id]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 10
  }
  instances                 = ["${aws_instance.amazon_server.id}", "${aws_instance.ubuntu_server.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 40
  tags = {
    Name = "WebServer-Highly-Available-ELB"
  }
}


data "aws_availability_zones" "available" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = data.aws_availability_zones.available.names[2]
}


resource "aws_route53_record" "www" {
  zone_id = "Z03826083D6Q2U2UR9XYE"
  name    = "dev.mirexcool.space"
  type    = "A"

  alias {
    name                   = aws_elb.web.dns_name
    zone_id                = aws_elb.web.zone_id
    evaluate_target_health = true
  }
}
