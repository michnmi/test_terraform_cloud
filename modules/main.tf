provider "aws" {
    region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"
  
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Kayla! Missed you!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = { 
      Name = "terraform-example"
  }

}
