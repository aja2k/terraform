resource "ncloud_login_key" "loginkey" {
  key_name = "test-key-bst"
}

resource "ncloud_vpc" "test3" {
  ipv4_cidr_block = "10.10.0.0/16"
}

resource "ncloud_subnet" "test3" {
  vpc_no         = ncloud_vpc.test3.vpc_no
  subnet         = cidrsubnet(ncloud_vpc.test3.ipv4_cidr_block, 8, 1)
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.test3.default_network_acl_no
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = "rocky-8.10-base"  # "rocky-8.10-base" , "ubuntu-22.04-base"
  filter {
    name = "hypervisor_type"
    values = ["KVM"]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = ["c2-g3"]
  }
}

resource "ncloud_init_script" "init" {
  name    = "ls-script"
  content = file("${path.module}/shell/init_script.sh")
}

resource "ncloud_server" "bastion_server" {
  subnet_no                 = ncloud_subnet.test3.id
  name                      = "tf-kvm-server"
  server_image_number       = data.ncloud_server_image_numbers.kvm-image.image_number_list.0.server_image_number
  server_spec_code          = data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  init_script_no            = ncloud_init_script.init.id
  #fee_system_type_code      = "FXSUM"
  #login_key_name            = "test-key-2"
}

# 공인 IP 할당
resource "ncloud_public_ip" "bastion_ip" {
  server_instance_no = ncloud_server.bastion_server.instance_no
}

# Export SSH Key
resource "local_sensitive_file" "ssh_key" {
  filename          = "./${ncloud_login_key.loginkey.key_name}.pem"
  content          = ncloud_login_key.loginkey.private_key
  file_permission  = "0600"
}

### Export Root Password ###
data "ncloud_root_password" "default" {
  server_instance_no = ncloud_server.bastion_server.instance_no 
  private_key = ncloud_login_key.loginkey.private_key 
}

resource "local_file" "bastion_svr_root_pw" {
  filename = "${ncloud_server.bastion_server.name}-root_password.txt"
  content = "${ncloud_server.bastion_server.name} => ${data.ncloud_root_password.default.root_password}"
}
