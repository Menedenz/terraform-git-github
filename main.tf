provider "aws"{
    region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.1.0/24"]

  tags = {
    Name = "test_git-vpc"
  }
}

resource "aws_security_group" "sg-1" {
    vpc_id = module.vpc.vpc_id
    name = "sg_1"

    ingress {
            from_port = "22"
            to_port = "22"
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
            from_port = "8080"
            to_port = "8080"
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        name = "test_git-sg"
    }
}

data "aws_ami" "latest_ami" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "access_key" {
    key_name = "key1"
    public_key = file("C:\\Users\\DualCloud\\.ssh\\id_rsa.pub")
}

resource "aws_instance" "EC2" {    
    ami = data.aws_ami.latest_ami.id
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    
    subnet_id = module.vpc.public_subnets[0]
    key_name = aws_key_pair.access_key.key_name
    vpc_security_group_ids = [aws_security_group.sg-1.id]

    associate_public_ip_address = true
    user_data = file("C:\\Users\\DualCloud\\Pictures\\terraform_with_git&github\\initial-script.sh")

    user_data_replace_on_change = true

    tags = {
        name = "test_git-EC2-vers-git-4-updated"
    }
}

# comment 1
# comment 2