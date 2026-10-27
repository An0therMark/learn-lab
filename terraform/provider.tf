terraform {
  required_providers {
    proxmox = {
        source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
    endpoint = "https://192.168.5.206:8006/"
    api_token = var.proxmox_api_token  
    insecure = true
    ssh {
      username = "root"
      private_key = file("/home/dsk1/.ssh/id_rsa_proxmox")
    }
}
