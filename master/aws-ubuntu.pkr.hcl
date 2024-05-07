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

source "amazon-ebs" "ubuntu-master" {
  ami_name      = "k8-master-aws-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "eu-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "k8-master-packer"
  sources = [
    "source.amazon-ebs.ubuntu-master"
  ]

  provisioner "shell" {
    inline = [
      "echo Upgrade",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "echo Upgrade complete",
      "echo Install ansible",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get -y install ansible",
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
