# fairground-machine-images

Buidling instances to satisfy [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) using packer and ansible.

Currently complete up to and includeing [Step 10](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/10-configuring-kubectl.md)

## Divergance

### CA
Files under packer/files/secret were created following [step 4](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md) of kubernetes the hard way and then sops encrypted.

### Step 10 configuring kubectl

Ran on the server rather than the jump box and added to the server build. Done this way as the cluster is often torn down, so local `/etc/hosts` would need to be frequently updated, and the cluster is run in a private subnet and accessed using session manager.

Trade off is the `admin.crt` and `admin.key` need to be on the server instance.

Context of `kubernetes-the-hard-way` is changed to `fairground` and there is a secret file of `kube-config` that is the resulting `~/.kube/config`, which is added to the root user. 

## usage

Decrypt the files under packer/files/secret. THe files need to be genereated and encrypted independently if you fork this repo.

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