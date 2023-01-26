#!/bin/bash
sudo yum -y update
sudo amazon-linux-extras install epel -y
sudo yum -y install ansible
sudo yum -y install git
sudo amazon-linux-extras install java-openjdk11
sudo chmod 400 /home/ec2-user/.ssh/Ansible-Node*
