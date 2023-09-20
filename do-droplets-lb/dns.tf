### Staging
resource "digitalocean_record" "www-staging" {
    domain = digitalocean_domain.staging.name
    type = "CNAME"
    name = "www"
    value = "@"
}

resource "digitalocean_record" "test-staging" {
    domain = digitalocean_domain.staging.id
    type = "A"
    name = "test"
    value = digitalocean_droplet.staging-1.ipv4_address
}

resource "digitalocean_domain" "staging" {
    name = "staging.${var.domain_name}"
    ip_address = digitalocean_loadbalancer.staging-lb.ip
}

### Production
resource "digitalocean_record" "www-production" {
    domain = digitalocean_domain.production.name
    type = "CNAME"
    name = "www"
    value = "@"
}

resource "digitalocean_record" "test-production" {
    domain = digitalocean_domain.production.id
    type = "A"
    name = "test"
    value = digitalocean_droplet.staging-1.ipv4_address
}

resource "digitalocean_domain" "production" {
    name = var.domain_name
    ip_address = digitalocean_loadbalancer.production-lb.ip
}
