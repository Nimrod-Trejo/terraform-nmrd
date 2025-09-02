output "my_ip_cidr" {
  description = "Your detected public IP in CIDR form"
  value       = local.my_ip_cidr
}

output "created_resources" {
  description = "Summary of created resources (Name + ID, plus details for instances)"
  value = {
    vpc = {
      name = aws_vpc.main.tags["Name"]
      id   = aws_vpc.main.id
    }
    subnet_public = {
      name = aws_subnet.public.tags["Name"]
      id   = aws_subnet.public.id
    }
    internet_gateway = {
      name = aws_internet_gateway.igw.tags["Name"]
      id   = aws_internet_gateway.igw.id
    }
    route_table_public = {
      name = aws_route_table.public.tags["Name"]
      id   = aws_route_table.public.id
    }
    route_table_assoc_public = {
      name = "${var.infra-prefix}-public-rt-assoc"
      id   = aws_route_table_association.public_assoc.id
    }
    security_group = {
      name = aws_security_group.app_sg.tags["Name"]
      id   = aws_security_group.app_sg.id
    }
    key_pair = {
      name = aws_key_pair.keypair.key_name
      id   = aws_key_pair.keypair.id
    }
    instances = [
      for i in aws_instance.example : {
        name      = i.tags["Name"]
        id        = i.id
        public_ip = i.public_ip
      }
    ]
  }
}
