#1. VPC 생성
resource "ncloud_vpc" "vpc" {
  name = local.vpc_name
  ipv4_cidr_block = var.network.vpc_cidr
}

# 2. 서브넷 생성
resource "ncloud_subnet" "subnets" {
  for_each = var.network.subnets

  vpc_no = ncloud_vpc.vpc.id
  name = "${var.env}-${each.value.name}" 
  subnet = each.value.cidr
  zone = contains(split("-", each.key), "1") ? "KR-1" : "KR-2"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type = each.value.type
  usage_type = each.value.usage
}

# 3. 라우팅 테이블 생성
resource "ncloud_route_table" "private" {
  vpc_no                = ncloud_vpc.vpc.id
  name                  = "${var.env}-pri-rt"
  supported_subnet_type = "PRIVATE"
}

resource "ncloud_route_table" "public" {
  vpc_no                = ncloud_vpc.vpc.id
  name                  = "${var.env}-pub-rt"
  supported_subnet_type = "PUBLIC"
}

# 4. 라우팅 테이블 연결
resource "ncloud_route_table_association" "subnet_associations" {
  for_each = var.network.subnets

  route_table_no = each.value.type == "PRIVATE" ? ncloud_route_table.private.id : ncloud_route_table.public.id
  subnet_no = ncloud_subnet.subnets[each.key].id
}

