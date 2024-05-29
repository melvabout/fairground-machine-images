# fairground-machine-images

Buidling instances to satisfy [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) using packer and ansible.

Currently complete up to and includeing [Step 8](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md)

## CA
Files under packer/files/secret were created following [step 4](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md) of kubernetes the hard way and then sops encrypted.

## usage

Decrypt the files under packer/files/secret

```bash
# server 
cd ./packer/server
packer build -var-file="config.pkrvars.hcl" aws-redhat.pkr.hcl
```

```bash
# node-<> 
cd ./packer/node-<node instance>
packer build -var-file="config.pkrvars.hcl" aws-redhat.pkr.hcl
```

Once built can be used as part of [fairground-infrastructure](https://github.com/melvabout/fairground-infrastructure) to build the Kubernetes Cluster.