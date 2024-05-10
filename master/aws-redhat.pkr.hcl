packer {
  required_plugins {
    amazon = {
      version = "1.3.2"
      source  = "github.com/hashicorp/amazon"
    }

    ansible = {
      version = "1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "redhat-master" {
  ami_name      = "k8-master-aws-redhat-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-west-2"
  source_ami_filter {
    filters = {
      name                = "*RHEL-9.*_HVM-*-x86_64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "k8-master-packer"
  sources = [
    "source.amazon-ebs.redhat-master"
  ]

  provisioner "shell" {
    inline = [
      "echo Upgrade",
      "sudo yum update -y",
      "echo Update complete",
      "echo Install ansible",
      "sudo yum install ansible-core -y",
      "echo ansible install complete",
    ]
  }

  provisioner "file" {
    source = "./files/"
    destination = "/tmp"
  }

  provisioner "ansible-local" {
    playbook_file = "./playbook.yml"
  }
}
