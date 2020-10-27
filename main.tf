provider "aws" {
  region     = "eu-north-1"
  access_key = var.access
  secret_key = var.secret
}


resource "aws_instance" "instance-1" {
  ami           = "ami-008dea09a148cea39"
  instance_type = "t3.micro"
  key_name      = "manual-key"

  network_interface {
    network_interface_id = aws_network_interface.network-1.id
    device_index         = 0
  }

  provisioner "remote-exec" {
    inline = ["echo ${aws_eip.one.public_ip} >> ~/IP-address.txt"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file("manual-key.pem")
    host        = self.public_ip
  }

  tags = {
    Name = "instance-1"
  }
}

resource "aws_instance" "instance-2" {
  ami           = "ami-008dea09a148cea39"
  instance_type = "t3.micro"
  key_name      = "manual-key"

  network_interface {
    network_interface_id = aws_network_interface.network-2.id
    device_index         = 0
  }

  provisioner "remote-exec" {
    inline = ["echo ${aws_eip.one.public_ip} >> ~/IP-address.txt"]
  }

    connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file("manual-key.pem")
    host        = self.public_ip
  }


  tags = {
    Name = "instance-2"
  }
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.ssh-key.public_key_openssh}"
}
