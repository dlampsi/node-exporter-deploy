variable "vm_name_prefix" {
  type    = string
  default = "vmsvc"
}

variable "vm_size" {
  type    = string
  default = "s-1vcpu-1gb"
}

variable "vm_region" {
  type    = string
  default = "fra1"
}

variable "pub_ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "private_ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_keys_ids" {
  type    = list(string)
  default = ["8b:20:90:e5:9c:48:6a:31:bd:27:d3:8d:f8:20:b5:47"]
}
