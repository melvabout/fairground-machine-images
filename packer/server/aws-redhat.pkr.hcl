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
  description = "The name to give to the machine."
}

variable "etcd_version" {
  type    = string
  description = "The version of etcd to install."
}

variable "kubernetes_version" {
  type    = string
  description = "The version of kubernetes to install."
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
      "sudo pip install boto3",
      "echo Python ready",
    ]
  }

  provisioner "file" {
    source = "../files/secret/id_rsa.pub"
    destination = "/tmp/id_rsa.pub"
  }

  provisioner "file" {
    source = "../files/secret/etcd"
    destination = "/tmp"
  }

  provisioner "file" {
    source = "../files/secret/kubernetes"
    destination = "/tmp"
  }

  provisioner "file" {
    source = "../files/populate_hosts.py"
    destination = "/tmp/populate_hosts.py"
  }

  provisioner "file" {
    source = "../files/secret/admin.kubeconfig"
    destination = "/tmp/admin.kubeconfig"
  }

  provisioner "file" {
    source = "../files/secret/kube-controller-manager.kubeconfig"
    destination = "/tmp/kube-controller-manager.kubeconfig"
  }

  provisioner "file" {
    source = "../files/secret/kube-scheduler.kubeconfig"
    destination = "/tmp/kube-scheduler.kubeconfig"
  }

   provisioner "file" {
    source = "../files/start_control_plane_services.sh"
    destination = "/tmp/start_control_plane_services.sh"
  }

  provisioner "file" {
    source = "../files/units/server-service"
    destination = "/tmp"
  }

  provisioner "file" {
    source = "../files/configs/kube-scheduler.yaml"
    destination = "/tmp/kube-scheduler.yaml"
  }

  provisioner "file" {
    source = "../files/configs/kube-apiserver-to-kubelet.yaml"
    destination = "/tmp/kube-apiserver-to-kubelet.yaml"
  }

  provisioner "ansible-local" {
    playbook_file = "./playbook.yml"
    extra_arguments = ["--extra-vars", "\"node_name=${var.node_name} etcd_version=${var.etcd_version} kubernetes_version=${var.kubernetes_version}\""]
  }

}
