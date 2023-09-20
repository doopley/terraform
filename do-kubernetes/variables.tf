variable "do_token" {
    description = "Digital Ocean Token"
    type = string
}

variable "do_ssh_key_name" {
    description = "Digital Ocean SSH Key Name"
    type = string
    default = "user-terraform"
}

variable "pvt_key" {
    description = "Private key"
    type = string
    default = "ssh_key"
}

variable "public_key" {
    description = "Public key"
    type = string
    default = "ssh_key.pub"
}

## K8s variables

variable "application_name" {
    type = string
    default = "app_name"
}

# doctl k8s options regions
variable "k8s_region" {
    type = string
    default = "fra1"
}

variable "k8s_node_count" {
    type = number
    default = 1
}

# doctl k8s options sizes
variable "k8s_size" {
    type = string
    default = "s-2vcpu-2gb"
}

# doctl k8s options versions
variable "k8s_version" {
    type = string
    default = "1.28.2-do.0"
}

## END K8s Variables
