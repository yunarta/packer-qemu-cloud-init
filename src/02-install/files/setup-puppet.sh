#!/bin/bash
cp /var/packer/files/zscaler.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
sh /var/packer/files/install-puppet.sh
sh /var/packer/files/modify_puppet_service.sh

#systemctl stop puppet
#/opt/puppetlabs/bin/puppet ssl clean
#cp /var/packer/files/csr_attributes.yaml /etc/puppetlabs/puppet
