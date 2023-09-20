## Pre-Requisites 
1. Terraform: Install Terraform on your MACOS by following these steps:
### Add hashicorp tap
```bash
brew tap hashicorp/tap
```

## Install terraform
```bash
brew install hashicorp/tap/terraform
```

## Check Terraform Version
```bash
terraform --version
```

2. Digital Ocean Account Token: You'll need a Digital Ocean Token to create and manage resources. Make sure you have your token ready.

## Setup Permissions for Scripts
```bash
chmod +x *.sh
```

## Projects
1. do-droplets-lb
2. do-kubernetes

**You can create additional projects starting from one of the two existing ones (do-droplets-lb or do-kubernetes) and customize them as you wish.**

Global Arguments:
- `username=*` : The username of the user to be created on the droplet.
- `do_token=*` : The Digital Ocean Token to be used to create the droplet.
- `project=*` : (do-droplets-lb, do-kubernetes)
- `--continue` : Setup the droplet without asking for any user input. Useful for CI/CD pipelines.

Select the Project
```bash
./run.sh username=<username> do_token=<do_token> project=<project_name> --continue
```

## Start the script

**When run without any arguments, it will ask for user input.**

**You can use an SSH key of your choice by renaming it with your username or create an SSH key automatically. Please keep in mind that once it's created or after placing the SSH key in the ./ssh_keys folder, you need to add it in the security settings within Digital Ocean.**

Arguments:
- `username=*` : The username of the user to be created on the droplet.
- `do_token=*` : The Digital Ocean Token to be used to create the droplet.
- `action=*` : (init, plan, apply) the terraform.
- `--continue` : Setup the droplet without asking for any user input. This is useful when you want to setup the droplet in a CI/CD pipeline.

```bash
./run.sh username=<username> do_token=<do_token> action=<init, plan, apply> --continue
```

## Destroy The Droplet

**When run without any arguments, it will ask for user input.**

Arguments:
- `username=*` : The username of the user to be created on the droplet.
- `do_token=*` : The Digital Ocean Token to be used to create the droplet.
- `action=*` : (destroy) the terraform.
- `--action-all=*` : (skip, remove) the below actions.
- `--action-ssh_key=*` : (skip, remove) the the ssh key created by terraform.
- `--action-terraform_root=*` : (skip, remove) the the terraform root folder.
- `--action-tfvars=*` : (skip, remove) the the terraform.tfvars file.
- `--action-tfstate=*` : (skip, remove) the the terraform.tfstate file.
- `--action-tfstate_backup=*` : (skip, remove) the the terraform.tfstate.backup file.
- `--action-setup_output=*` : (skip, remove) the the setup output file.
- `--clean` : Clean the Terraform files and folders (remove all files and folders created by Terraform).
- `--destroy` : Destroy the droplet and the resources created by Terraform (does not remove SSH key and tfvars file).

Destroy the droplet and all the resources created by terraform.
```bash
./run.sh username=<username> do_token=<do_token> action=destroy
```

- with --destroy argument, it will destroy the droplet and all the resources created by terraform (no remove ssh key and tfvars file)
```bash
./run.sh username=<username> do_token=<do_token> --destroy --continue
```

- clean the terraform files and folders (remove all files and folders created by terraform, ssh key and tfvars)
```bash
./run.sh username=<username> do_token=<do_token> --clean --continue
```

- with arguments for actions
#### Action for all (when --action=destroy)

```bash
./run.sh username=<username> do_token=<do_token> action=destroy --action-all=<skip, remove>
```

```bash
./run.sh username=<username> do_token=<do_token> action=destroy --action-ssh_key=<skip, remove> --action-terraform_root=<skip, remove> --action-tfvars=<skip, remove> --action-tfstate=<skip, remove> --action-tfstate_backup=<skip, remove> --action-setup_output=<skip, remove>
```

## DNS Configuration with GoDaddy

Create a new DNS record of type "Nameserver". Add only the name of the sub-domain like "pentest" in the host field and in the points to field add the Nameserver DNS of Digital Ocean:

- ns1.digitalocean.com
- ns2.digitalocean.com
- ns3.digitalocean.com

No configuration needs to be done on Digital Ocean's side as that is being managed by the Terraform script.
