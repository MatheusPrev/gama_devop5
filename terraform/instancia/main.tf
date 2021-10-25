terraform {
  required_version = ">= 0.12" # colocando compatibilidade do terraform para 0.12
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #subnet_id     = "subnet-009732771798c000e"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = ["${aws_security_group.permitir_ssh.id}"]
  key_name      = "key_matheus_dev_ubunto"
  
  associate_public_ip_address = true
  
  root_block_device {
    volume_size = 8
    encrypted = true
  }
    
  tags = {
    Name = "ec2-matheus-deploy-1"
  }
}
