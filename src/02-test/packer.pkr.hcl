packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "sha1sum" {
  default = ""
}

source "qemu" "redhat" {
  format     = "qcow2"
  disk_image = true


  iso_url      = "../composer-api-dd9a4349-c395-4b3d-b9a2-005655901c52-disk.qcow2"
  iso_checksum = "none"
  # iso_checksum = "sha1:${var.sha1sum}"

  shutdown_command = "sudo shutdown -P now"
  accelerator      = "kvm"

  ssh_username = "packer"
  # ssh_password = "root"
  ssh_private_key_file = "../id_rsa"
  ssh_timeout          = "20m"

  vm_name = "build.qcow2"

  net_device     = "virtio-net"
  disk_interface = "virtio"

  memory = 4096

  qemuargs = [
    ["-smp", "cores=4,threads=2"],
    ["-m", "4096"],
    ["-machine", "accel=hvf:kvm:whpx:tcg,type=pc"],
    # ["-snapshot"],
    ["-boot", "d"],
    ["-drive", "file=output-redhat/build.qcow2"],
    ["-drive", "file=cloud-init.iso,if=virtio,index=1,media=cdrom"]
  ]

  boot_wait = "20s"

  //   boot_command     = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6-ks.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.redhat"]

  provisioner "breakpoint" {
  }
}