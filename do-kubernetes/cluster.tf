resource "digitalocean_kubernetes_cluster" "clustr_name" {
    name = var.application_name
    region = var.k8s_region
    version = var.k8s_version

    node_pool {
        name = "${var.application_name}-worker-pool"
        size = var.k8s_size
        node_count = var.k8s_node_count
    }
}
