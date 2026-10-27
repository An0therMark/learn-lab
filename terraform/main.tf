# This is the main file, that declares what terraform should do. Every action is a "resource", with EXACT hook name, and then given name. 

# First key here is a HOOK NAME. It needs to be EXACT, and is defined by a provider, and needs to be looked up. Here it's "proxmox_virtual_environment_vm", which is a hook for working with VMs, creating and changing them. 
# For examle, if I need to download file (cloud image), I would need to use "proxmox_virtual_environment_download_file" Second key is just a given name, can be anything
resource "proxmox_virtual_environment_vm" "k8s_lab" {
  for_each = var.vms # Here is is a loop, that will do the action for every object in "vms" variable, that I declared in variables file 

  name = each.value.name # This is interesting syntax, but it is very straightforward. each.value just means it will look at the objects in the list I gave it, and extract the name string, that I declared. 
  node_name = "pvetest" # hostname of my proxmox server
  vm_id = 300 + index(keys(var.vms), each.key) # Okay, this is I can't fully comprehend, but from what I could gather it is a way to extract numeric IDs from objects in a list (a map?) this expression sorts the objects, and assigns keys to them, looking at the current one  with "each.key", and adding it to 300

  clone { # Also a very straightforward block, that clones a template from a template
    vm_id = 9000
    full = true # Note on this key - full clone is it's own independant VM with own drive. But if set to "false", it's a LINKED clone. Basically it's using template's virtual drive in RO mode, ONLY WRITING CHANGES IN ITS OWN DRIVE. That might save a LOT of space, but it's fully dependant on the template to be intact
  }

  description = "terraform for k8s lab"

  agent { # Enabling QEMU agent 
    enabled = true
  }

  cpu { 
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "main"
    interface = "scsi0"
    size = each.value.disk_size
  }
  
  serial_device { # I am not sure why tutorial have this even set up, considering that socket is a default anyway. This block simply specifies the way serial console works. Here it's just using standart virtual unix socket for interacting with VM
    device = "socket"
  }

  initialization { # Essentially a cloud-init. This block allows to configure VMs on first boot - set up user accounts, IP addresses, DNS, hostname and more. Can even pass cloud-init file here
    ip_config {
        ipv4 {
            address = "dhcp"
        }
    }

  }

  network_device {
    bridge = "vmbr1"
    model = "virtio"
  }

  operating_system { # Also something from the tutorial. It says, that even though it is optional, it is preferred to specify the OS type here, because otherwise proxmox can fallback to the default, older setting that limits stuff
    type = "l26"
  }
}
