resource "aws_security_group" "permitir_ssh" {
  name        = "matheus_sg_terraform_ssh1"
  description = "Permitindo acesso ssh para as maquinas terraform"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Liberando SSH de entrada"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "Liberando a saida"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "permitir_ssh"
  }
}
