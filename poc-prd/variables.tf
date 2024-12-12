variable "region" {
  description = "네이버 클라우드 리전"
  type        = string
  default     = "KR"
}

variable "access_key" {
  description = "Naver Cloud Platform access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Naver Cloud Platform secret key"
  type        = string
  sensitive   = true
}

variable "env" {
  description = "environment"
  type        = string
  default     = "poc-prd"
}

variable "clusters" {
  description = "cluster configuration"
  type = map(object({
    name        = string
    environment = string
    zone        = string
    nodepool = object({
      node_count = number
      storage_size = number
      autoscale = object({
        min = number
        max = number
      })
      labels = map(string)
    })
  }))
  default = {
    bof-1 = {
      name        = "bof"
      environment = "prd"
      zone        = "KR-1"
      nodepool = {
        node_count = 4
        storage_size = 600
        autoscale = {
          min = 4
          max = 8
        }
        labels = {
          "role" = "worker"
          "environment" = "prd-bof-1"
        }
      }
    }
    bof-2 = {
      name        = "bof"
      environment = "prd"
      zone        = "KR-2"
      nodepool = {
        node_count = 1
        storage_size = 600
        autoscale = {
          min = 1
          max = 1
        }
        labels = {
          "role" = "worker"
          "environment" = "prd-bof-2"
        }
      }
    }
    cmn-1 = {
      name        = "cmn"
      environment = "prd"
      zone        = "KR-1"
      nodepool = {
        node_count = 4
        storage_size = 600
        autoscale = {
          min = 4
          max = 8
        }
        labels = {
          "role" = "worker"
          "environment" = "prd-cmn-1"
        }
      }
    }
    cmn-2 = {
      name        = "cmn"
      environment = "prd"
      zone        = "KR-2"
      nodepool = {
        node_count = 1
        storage_size = 600
        autoscale = {
          min = 1
          max = 1
        }
        labels = {
          "role" = "worker"
          "environment" = "prd-cmn-2"
        }
      }
    }
  }
}

variable "network" {
  description = "네트워크 설정"
  type = object({
    vpc_cidr = string
    subnets = map(object({
      name = string
      cidr = string
      type = string
      usage = string
    }))
  })
  default = {
    vpc_cidr = "10.101.0.0/16"
    subnets = {
      # BOF Zone 1
      "bof-lb-pub-1" = {
        name = "bof-lb-pub-sbn-1"
        cidr = "10.101.1.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "bof-vm-pub-1" = {
        name = "bof-vm-pub-sbn-1"
        cidr = "10.101.2.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "bof-lb-pri-1" = {
        name = "bof-lb-pri-sbn-1"
        cidr = "10.101.3.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "bof-vm-pri-1" = {
        name = "bof-vm-pri-sbn-1"
        cidr = "10.101.4.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "bof-np-pri-1" = {
        name = "bof-np-pri-sbn-1"
        cidr = "10.101.5.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # BOF Zone 2
      "bof-lb-pub-2" = {
        name = "bof-lb-pub-sbn-2"
        cidr = "10.101.101.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "bof-vm-pub-2" = {
        name = "bof-vm-pub-sbn-2"
        cidr = "10.101.102.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "bof-lb-pri-2" = {
        name = "bof-lb-pri-sbn-2"
        cidr = "10.101.103.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "bof-vm-pri-2" = {
        name = "bof-vm-pri-sbn-2"
        cidr = "10.101.104.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "bof-np-pri-2" = {
        name = "bof-np-pri-sbn-2"
        cidr = "10.101.105.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # CMN Zone 1
      "cmn-lb-pub-1" = {
        name = "cmn-lb-pub-sbn-1"
        cidr = "10.101.6.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "cmn-vm-pub-1" = {
        name = "cmn-vm-pub-sbn-1"
        cidr = "10.101.7.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "cmn-lb-pri-1" = {
        name = "cmn-lb-pri-sbn-1"
        cidr = "10.101.8.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "cmn-vm-pri-1" = {
        name = "cmn-vm-pri-sbn-1"
        cidr = "10.101.9.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "cmn-np-pri-1" = {
        name = "cmn-np-pri-sbn-1"
        cidr = "10.101.10.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # CMN Zone 2
      "cmn-lb-pub-2" = {
        name = "cmn-lb-pub-sbn-2"
        cidr = "10.101.106.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "cmn-vm-pub-2" = {
        name = "cmn-vm-pub-sbn-2"
        cidr = "10.101.107.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "cmn-lb-pri-2" = {
        name = "cmn-lb-pri-sbn-2"
        cidr = "10.101.108.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "cmn-vm-pri-2" = {
        name = "cmn-vm-pri-sbn-2"
        cidr = "10.101.109.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "cmn-np-pri-2" = {
        name = "cmn-np-pri-sbn-2"
        cidr = "10.101.110.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
    }
  }
}


