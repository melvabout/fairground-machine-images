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

variable "node_name" {
  type    = string
  description = "The name to give to the machine"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "redhat-k8" {
  ami_name      = "k8-${var.node_name}-aws-redhat-${local.timestamp}"
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
  name = "redhat-k8-packer"
  sources = [
    "source.amazon-ebs.redhat-k8"
  ]

  provisioner "shell" {
    inline = [
      "echo Upgrade",
      "sudo yum update -y",
      "echo Update complete",
      "echo Install ansible",
      "sudo yum install ansible-core -y",
      "echo Ansible install complete",
      "echo Setup python",
      "sudo yum install python3-pip -y",
      "sudo pip install -y boto3",
      "echo Python ready",
    ]
  }

  provisioner "file" {
    source = "../files/secret/id_rsa.pub"
    destination = "/tmp/id_rsa.pub"
  }

  provisioner "file" {
    source = "../files/secret/ca.key"
    destination = "/tmp/ca.key"
  }

  provisioner "file" {
    source = "../files/secret/ca.crt"
    destination = "/tmp/ca.crt"
  }

  provisioner "file" {
    source = "../files/secret/kube-api-server.key"
    destination = "/tmp/kube-api-server.key"
  }

  provisioner "file" {
    source = "../files/secret/kube-api-server.crt"
    destination = "/tmp/kube-api-server.crt"
  }

  provisioner "file" {
    source = "../files/secret/service-accounts.key"
    destination = "/tmp/service-accounts.key"
  }

  provisioner "file" {
    source = "../files/secret/service-accounts.crt"
    destination = "/tmp/service-accounts.crt"
  }

  provisioner "file" {
    source = "../files/populate_hosts.py"
    destination = "/tmp/id_rsa.pub"
  }

  provisioner "ansible-local" {
    playbook_file = "./playbook.yml"
    extra_arguments = ["--extra-vars", "\"node_name=${var.node_name}\""]
  }

}
