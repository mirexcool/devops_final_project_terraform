#-------------------------------------------------
# My terraform file
#
# Outputs
#
# Created by Yevhen Yefimov
#
#--------------------------------------------------
output "ansible_public_ip" {
  description = "Ansible Master public IP"
  value       = aws_instance.masterAnsible.public_ip
}

output "amazon_server_public_ip" {
  description = "Amazon Webserver (amazon_server) public IP"
  value       = aws_instance.amazon_server.public_ip
}

output "ubuntu_server_public_ip" {
  description = "Ubuntu Webserver (ubuntu_server) public IP"
  value       = aws_instance.ubuntu_server.public_ip
}

output "java_agent_public_ip" {
  description = "Ubuntu Webserver (java agent) public IP"
  value       = aws_instance.java_agent.public_ip
}

output "dev_stage_record" {
  description = "Dev Stage Domain Name"
  value       = aws_route53_record.dev_stage_record.name
}

output "jenkins_stage_record" {
  description = "Jenkins Domain Name"
  value       = aws_route53_record.jenkins.name
}
