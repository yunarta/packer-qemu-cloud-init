packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "redhat" {
  format = "qcow2"
  disk_image = true
  use_backing_file = true

  iso_url      = "../composer-api-dd9a4349-c395-4b3d-b9a2-005655901c52-disk.qcow2"
  iso_checksum = "none"

  shutdown_command = "sudo shutdown -P now"
  accelerator      = "tcg"

  ssh_username         = "packer"
  ssh_private_key_file = "../id_rsa"
  ssh_timeout          = "20m"

  vm_name = "install.qcow2"

  net_device     = "virtio-net"
  disk_interface = "virtio"

  memory = 4096
  qemuargs = [
    ["-smp", "4,sockets=1,cores=4,threads=1"],
    ["-m", "4096"],
    ["-cpu", "max"],
    ["-device", "virtio-gpu"],
    ["-display", "cocoa,show-cursor=on"],
    ["-boot", "d"],
    ["-drive", "file=output-redhat/install.qcow2,if=virtio,cache=writeback"],
    ["-drive", "file=cloud-init.iso,if=virtio,index=1,media=cdrom"]
  ]

  boot_wait = "30s"
}

build {
  sources = ["source.qemu.redhat"]

  provisioner "file" {
    source      = "files"
    destination = "/var/packer"
  }

  provisioner "shell" {
    remote_folder = "/var/packer"
    inline = [
      "sudo sh /var/packer/files/setup-puppet.sh"
    ]
  }
}