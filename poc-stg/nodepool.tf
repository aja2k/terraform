# 서버 이미지 조회
data "ncloud_nks_server_images" "image"{
  hypervisor_code = "KVM"
  filter {
    name = "label"
    values = ["ubuntu-22.04"]
    regex = true
  }
}

data "ncloud_nks_server_products" "product" {
  for_each = var.clusters

  software_code = data.ncloud_nks_server_images.image.images[0].value
  zone = each.value.zone

  filter {
    name = "product_type"
    values = ["STAND"]
  }

  filter {
    name = "cpu_count"
    values = ["4"]
  }

  filter {
    name = "memory_size"
    values = ["16GB"]
  }
}

# 노드풀  생성
resource "ncloud_nks_node_pool" "node_pool" {
  for_each = var.clusters

  cluster_uuid = ncloud_nks_cluster.clusters[each.key].uuid
  node_pool_name = local.clusters[each.key].resource_names.nodepool
  node_count = each.value.nodepool.node_count
  software_code = data.ncloud_nks_server_images.image.images[0].value
  server_spec_code = data.ncloud_nks_server_products.product[each.key].products[0].value
  storage_size = each.value.nodepool.storage_size
  subnet_no_list = [ncloud_subnet.subnets["${each.value.name}-np-pri-${split("-", each.key)[1]}"].id]

  autoscale {
    enabled = true
    min = each.value.nodepool.autoscale.min
    max = each.value.nodepool.autoscale.max
  }

  dynamic "label" {
    for_each = each.value.nodepool.labels
    content {
      key = label.key
      value = label.value
    }
  }
}


