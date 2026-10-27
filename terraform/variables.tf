variable "proxmox_api_token" {
    type    = string
    description = "proxmox tf api token"
    sensitive = true
  
}

variable "vms" {
    description = "VM configs"
    type = map(object({
        name    = string
        cores   = number
        memory  = number
        disk_size   = number
    }))
    default = {
      "jumpbox" = {
        name = "jumpbox"
        cores = 1
        memory = 512
        disk_size = 10
      }
      "k8s-server" = {
        name = "k8s-server"
        cores = 1
        memory = 2048
        disk_size = 20
      }
      "k8s-node-0" = {
        name = "k8s-node-0"
        cores = 1
        memory = 2048
        disk_size = 20
      }       
      "k8s-node-1" = {
        name = "k8s-node-1"
        cores = 1
        memory = 2048
        disk_size = 20
      }
    }
}