provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ou ["099720109477"] ID master com permissão para busca

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64-*"] # exemplo de como listar um nome de AMI - 'aws ec2 describe-images --region us-east-1 --image-ids ami-09e67e426f25ce0d7' https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
  }
}

#resource "aws_ami_from_instance" "maquina_master" {
# name          = "devop5_multi_master-${count.index}-${var.versao}"
# source_instance_id = var.resource_id
# count = 3
#}

resource "aws_instance" "maquina_master" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.large"
  key_name      = "devop5_jenkins_out"
  tags = {
    Name = "devop5_multi_master-${count.index}"
  }
  subnet_id                   = "subnet-0dbc6439c94e66d76"
  associate_public_ip_address = true

  root_block_device {
    encrypted = true
    volume_size = 20
  }

  vpc_security_group_ids = ["${aws_security_group.acessos_master.id}"]
  count                  = 3
}


resource "aws_instance" "workers" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "devop5_jenkins_out"
  tags = {
    Name = "devop5_multi_worker-${count.index}"
  }
  subnet_id                   = "subnet-0dbc6439c94e66d76"
  associate_public_ip_address = true
  root_block_device {
    encrypted = true
    #kms_key_id  = "arn:aws:kms:us-east-1:534566538491:key/90847cc8-47e8-4a75-8a69-2dae39f0cc0d"
    volume_size = 20
  }

  vpc_security_group_ids = ["${aws_security_group.acessos_workers.id}"]
  count                  = 3
}

resource "aws_instance" "haproxy" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "devop5_jenkins_out"
  tags = {
    Name = "devop5_multi_haproxy"
  }
  subnet_id                   = "subnet-0dbc6439c94e66d76"
  associate_public_ip_address = true
  root_block_device {
    encrypted = true
    volume_size = 20
  }

  vpc_security_group_ids = ["${aws_security_group.acessos_workers.id}"]
}


resource "aws_security_group" "acessos_workers" {
  name        = "devop5_multi_workers_sg"
  description = "acessos_workers inbound traffic"
  vpc_id      = "vpc-000ac43d9700f2e6c"

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "SSH from VPC"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "sg-08a85b775215cdbb0","sg-00a34edce2a2b70c7"
      ]
      self    = false
      to_port = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "devop5_multi_acessos_workers"
  }
}

resource "aws_security_group" "acessos_master" {
  name        = "devop5_multi_master_sg"
  description = "acessos_workers inbound traffic"
  vpc_id      = "vpc-000ac43d9700f2e6c"

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "SSH from VPC"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = ["sg-08a85b775215cdbb0",]
      #security_groups = null,
      self    = false
      to_port = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "devop5_multi_acessos_master"
  }
}



variable "resource_id" {
  type        = string
  description = "Qual o id da máquina?"
}

variable "versao" {
  type        = string
  description = "Qual a versão da imagem?"
}

output "k8s-masters" {
  value = [
    for key, item in aws_instance.maquina_master :
      "k8s-master ${key+1} - ${item.private_ip} - ssh -i ~/.ssh/id_rsa ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_workers" {
  value = [
    for key, item in aws_instance.workers :
      "k8s-workers ${key+1} - ${item.private_ip} - ssh -i ~/.ssh/id_rsa ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-haproxy" {
  value = [
    "k8s_proxy - ${aws_instance.haproxy.private_ip} - ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.haproxy.public_dns} -o ServerAliveInterval=60"
  ]
}
