# fairground-machine-images

Buidling instances to satisfy [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) using packer and ansible.
Having to skip some bits like DNS as they won't be known till the instance is launched.

## usage

```bash
cd ./packer
packer build -var-file="../config/<node to build>/config.pkrvars.hcl" aws-redhat.pkr.hcl
```