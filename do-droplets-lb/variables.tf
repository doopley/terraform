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

variable "domain_name" {
    description = "Domain Name"
    type = string

    default = "domain.com"
}

variable "os" {
    description = "Base OS"
    type = string
    default = "ubuntu-20-04-x64"
}

variable "region" {
    description = "Region of Deployment"
    type = string
    default = "fra1"
}

variable "size" {
    description = "Droplet Size"
    type = string
    default = "s-2vcpu-4gb"
}
