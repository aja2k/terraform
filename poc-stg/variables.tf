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
  default     = "poc-stg"
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
      environment = "stg"
      zone        = "KR-1"
      nodepool = {
        node_count = 2
        storage_size = 600
        autoscale = {
          min = 2
          max = 4
        }
        labels = {
          "role" = "worker"
          "environment" = "stg-bof-1"
        }
      }
    }
    bof-2 = {
      name        = "bof"
      environment = "stg"
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
          "environment" = "stg-bof-2"
        }
      }
    }
    cmn-1 = {
      name        = "cmn"
      environment = "stg"
      zone        = "KR-1"
      nodepool = {
        node_count = 2
        storage_size = 600
        autoscale = {
          min = 2
          max = 4
        }
        labels = {
          "role" = "worker"
          "environment" = "stg-cmn-1"
        }
      }
    }
    cmn-2 = {
      name        = "cmn"
      environment = "stg"
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
          "environment" = "stg-cmn-2"
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
    vpc_cidr = "10.102.0.0/16"
    subnets = {
      # BOF Zone 1
      "bof-lb-pub-1" = {
        name = "bof-lb-pub-sbn-1"
        cidr = "10.102.1.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "bof-vm-pub-1" = {
        name = "bof-vm-pub-sbn-1"
        cidr = "10.102.2.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "bof-lb-pri-1" = {
        name = "bof-lb-pri-sbn-1"
        cidr = "10.102.3.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "bof-vm-pri-1" = {
        name = "bof-vm-pri-sbn-1"
        cidr = "10.102.4.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "bof-np-pri-1" = {
        name = "bof-np-pri-sbn-1"
        cidr = "10.102.5.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # BOF Zone 2
      "bof-lb-pub-2" = {
        name = "bof-lb-pub-sbn-2"
        cidr = "10.102.101.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "bof-vm-pub-2" = {
        name = "bof-vm-pub-sbn-2"
        cidr = "10.102.102.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "bof-lb-pri-2" = {
        name = "bof-lb-pri-sbn-2"
        cidr = "10.102.103.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "bof-vm-pri-2" = {
        name = "bof-vm-pri-sbn-2"
        cidr = "10.102.104.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "bof-np-pri-2" = {
        name = "bof-np-pri-sbn-2"
        cidr = "10.102.105.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # CMN Zone 1
      "cmn-lb-pub-1" = {
        name = "cmn-lb-pub-sbn-1"
        cidr = "10.102.6.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "cmn-vm-pub-1" = {
        name = "cmn-vm-pub-sbn-1"
        cidr = "10.102.7.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "cmn-lb-pri-1" = {
        name = "cmn-lb-pri-sbn-1"
        cidr = "10.102.8.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "cmn-vm-pri-1" = {
        name = "cmn-vm-pri-sbn-1"
        cidr = "10.102.9.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "cmn-np-pri-1" = {
        name = "cmn-np-pri-sbn-1"
        cidr = "10.102.10.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      # CMN Zone 2
      "cmn-lb-pub-2" = {
        name = "cmn-lb-pub-sbn-2"
        cidr = "10.102.106.0/24"
        type = "PUBLIC"
        usage = "LOADB"
      }
      "cmn-vm-pub-2" = {
        name = "cmn-vm-pub-sbn-2"
        cidr = "10.102.107.0/24"
        type = "PUBLIC"
        usage = "GEN"
      }
      "cmn-lb-pri-2" = {
        name = "cmn-lb-pri-sbn-2"
        cidr = "10.102.108.0/24"
        type = "PRIVATE"
        usage = "LOADB"
      }
      "cmn-vm-pri-2" = {
        name = "cmn-vm-pri-sbn-2"
        cidr = "10.102.109.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
      "cmn-np-pri-2" = {
        name = "cmn-np-pri-sbn-2"
        cidr = "10.102.110.0/24"
        type = "PRIVATE"
        usage = "GEN"
      }
    }
  }
}


