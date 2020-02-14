provider "aws" {
    region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, mate! Missed you!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = { 
      Name = "terraform-example"
  }

}
