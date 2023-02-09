#-------------------------------------------------
# My terraform file
#
# Launch Java Agent
#
# Created by Yevhen Yefimov
#
#--------------------------------------------------

# Create Java Agent by saved AMI.
resource "aws_instance" "java_agent" {
  ami                    = "ami-0559afb177e055245" # Java agent AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.java_agent_sg.id]

  tags = {
    Name  = "Java Agent Server"
    Owner = "mirexcool"
  }
  key_name = "UbuntuJenkins"
}

# Link the eip to Java Agent instance.
resource "aws_eip_association" "java_agent_eip" {
  instance_id   = aws_instance.java_agent.id
  allocation_id = "eipalloc-0f0590e870ecfd4c6"
}

# Create Security Group for Java Agent.
resource "aws_security_group" "java_agent_sg" {
  name        = "Java Agent Security Group"
  description = "Default SG for Java Agent Server"

  ingress {
    from_port   = 22 #SSH port
    to_port     = 22
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
    Name  = "Java Agent SG"
    Owner = "mirexcool"
  }

}
