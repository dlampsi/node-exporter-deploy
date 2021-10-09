data "template_file" "inventory" {
  template = file("templates/inventory.tpl")

  vars = {
    node_exporter_group = join(
      "\n",
      formatlist("%s    ansible_host=%s",
        digitalocean_droplet.vmsvc.*.name,
        digitalocean_droplet.vmsvc.*.ipv4_address,
      ),
    )
  }
}

resource "null_resource" "update_inventory" {
  triggers = {
    template = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ../ansible/inventory"
  }
}
