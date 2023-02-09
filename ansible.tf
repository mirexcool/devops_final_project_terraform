#-------------------------------------------------
# My terraform file
#
# Startup Ansible agent
#
# Created by Yevhen Yefimov
#
#--------------------------------------------------

# Create instance for Ansible using Amazon AMI.
resource "aws_instance" "masterAnsible" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ansible_master_sg.id]
  user_data              = file("user_data/ansible_user_data.sh")

  # Transfer keys to Ansible.
  provisioner "file" {
    source      = "keys/Ansible-Node-1.pem"
    destination = "/home/ec2-user/.ssh/Ansible-Node-1.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keys/Ansible-Master.pem")
      host        = self.public_ip
    }
  }
    # Transfer keys to Ansible.
  provisioner "file" {
    source      = "keys/Ansible-Node-2.pem"
    destination = "/home/ec2-user/.ssh/Ansible-Node-2.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keys/Ansible-Master.pem")

      host = self.public_ip
    }
  }

  tags = {
    Name  = "Ansible Master Server"
    Owner = "mirexcool"
  }
  key_name = "Ansible-Master"
}

# Link the eip to Ansible instance.
resource "aws_eip_association" "ansible_eip" {
  instance_id   = aws_instance.masterAnsible.id
  allocation_id = "eipalloc-0c7eeee7a13d4554d"
}

# Create Security Group for Ansible.
resource "aws_security_group" "ansible_master_sg" {
  name        = "Ansible Master Security Group"
  description = "Default SG for Ansible Master Server"

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
    Name  = "Ansible Master SG"
    Owner = "mirexcool"
  }
}