##############################################
# NETWORK MODULE OUTPUTS
# modules/network/outputs.tf
##############################################

output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "host_sg_id" { value = aws_security_group.host.id }
