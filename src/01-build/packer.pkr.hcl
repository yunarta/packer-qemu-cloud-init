packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "redhat" {
  format           = "qcow2"
  disk_image       = true
  use_backing_file = true

  # iso_url      = "/home/yunarta/Downloads/rhel-8.10-x86_64-boot.iso"
  # iso_checksum = "sha1:50bbf86bb537bf3d4a5ae14afe36f29b0975bf79"

  iso_url      = "/home/yunarta/Projects/packer/src/composer-api-dd9a4349-c395-4b3d-b9a2-005655901c52-disk.qcow2"
  iso_checksum = "sha1:b513fc9e0cb0297539dd73c0ef3d3e1c543bba76"

  shutdown_command = "sudo /usr/local/bin/packer_cleanup.sh"
  # disk_size        = "1000M"
  # skip_resize_disk = true

  accelerator = "kvm"

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

  provisioner "file" {
    source      = "files/cloud-init"
    destination = "/var/packer/cloud-init"
  }

  provisioner "shell" {
    remote_folder   = "/var/packer"
    remote_file     = "pre-setup"
    execute_command = "sudo chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    scripts = [
      "files/01-pre-setup.sh"
    ]
  }


  provisioner "file" {
    sources = [
      "/var/log/cloud-init.log",
      "/var/log/cloud-init-output.log"
    ]

    destination = "log/"
    direction   = "download"
  }

  # provisioner "breakpoint" {
  # }
}