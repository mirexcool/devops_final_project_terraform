#-------------------------------------------------
# My terraform file
#
# Making a jenkins server to be avaiable on
# jenkins.mirexcool.space
#
# Created by Yevhen Yefimov
#
#--------------------------------------------------

# Create a Elastic Load Balancer.
resource "aws_elb" "jenkins" {
  name               = "Jenkins-ELB"
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
    target              = "HTTP:8080/login"
    interval            = 10
  }
  # Put Jenkins instance to list.
  instances                 = ["i-0fd6787722b3b3acc"]
  cross_zone_load_balancing = true
  idle_timeout              = 80
  tags = {
    Name = "Jenkins-ELB"
  }
}

# Create a record to Route 53.
resource "aws_route53_record" "jenkins" {
  zone_id = "Z03826083D6Q2U2UR9XYE"
  name    = "jenkins.mirexcool.space"
  type    = "A"

  alias {
    name                   = aws_elb.jenkins.dns_name
    zone_id                = aws_elb.jenkins.zone_id
    evaluate_target_health = true
  }
}
