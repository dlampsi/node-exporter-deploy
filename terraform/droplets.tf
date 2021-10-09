resource "digitalocean_droplet" "vmsvc" {
  count    = 0
  image    = "centos-8-x64"
  name     = "${var.vm_name_prefix}-${count.index}"
  region   = var.vm_region
  size     = var.vm_size
  tags     = []
  ssh_keys = var.ssh_keys_ids

  provisioner "remote-exec" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.private_ssh_key)
    }
    inline = [
      "yum install python3 -y",
    ]
  }
}

output "droplet_ip_addresses" {
  value = {
    for droplet in digitalocean_droplet.vmsvc :
    droplet.name => droplet.ipv4_address
  }
}
