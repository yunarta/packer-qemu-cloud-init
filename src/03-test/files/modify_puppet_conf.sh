#!/bin/bash
HOSTNAME=$(hostname)-$(uuidgen)
PUPPET_CONF="/etc/puppetlabs/puppet/puppet.conf"

if grep -q "^certname" "$PUPPET_CONF"; then
    sed -i "s/^certname.*/certname = $HOSTNAME/" "$PUPPET_CONF"
    echo "Replaced existing certname with $HOSTNAME."
else
    echo "Adding certname = $HOSTNAME to $PUPPET_CONF."
    echo "certname = $HOSTNAME" >> "$PUPPET_CONF"
fi