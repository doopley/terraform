resource "digitalocean_droplet" "staging-1" {
    image = var.os
    name = "staging-1"
    region = var.region
    size = var.size
    tags = ["staging"]
    ssh_keys = [
        data.digitalocean_ssh_key.terraform.id
    ]
    
    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "export PATH=$PATH:/opt/terraform",
            # install nginx
            "sudo apt update",
            "sudo apt install -y nginx"
        ]
    }
}

resource "digitalocean_droplet" "staging-2" {
    image = var.os
    name = "staging-2"
    region = var.region
    size = var.size
    tags = ["staging"]
    ssh_keys = [
        data.digitalocean_ssh_key.terraform.id
    ]
    
    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            "export PATH=$PATH:/opt/terraform",
            # install nginx
            "sudo apt update",
            "sudo apt install -y nginx"
        ]
    }
}

resource "digitalocean_loadbalancer" "staging-lb" {
    name = "staging-lb"
    region = var.region

    forwarding_rule {
        entry_port = 80
        entry_protocol = "http"

        target_port = 80
        target_protocol = "http"
    }

    healthcheck {
        port = 22
        protocol = "tcp"
    }

    droplet_ids = [digitalocean_droplet.staging-1.id, digitalocean_droplet.staging-2.id ]
}
