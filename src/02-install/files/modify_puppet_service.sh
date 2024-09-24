#!/bin/bash
# Create a backup of the service file
# Check if cloud-init.target is already in the file
if grep -q "cloud-init.target" "/usr/lib/systemd/system/puppet.service"; then
    echo "cloud-init.target is already present in the puppet.service file. No changes needed."
    exit 0
else
    echo "cloud-init.target not found. Adding cloud-init.target dependencies."

    # Modify the Puppet service file to fix the ordering cycle issue
    echo "Modifying the puppet.service file to start after cloud-init."

    sed -i -e '/^Wants=/s/basic\.target/cloud-init.target/' \
            -e '/^After=/s/basic\.target/cloud-init.target/' \
            -e '/^WantedBy=/s/multi-user\.target/cloud-init.target/' \
            /usr/lib/systemd/system/puppet.service

    # Reload systemd daemon to apply changes
    echo "Reloading systemd daemon."
    systemctl daemon-reload
    systemctl disable puppet.service
    systemctl enable puppet.service

    # Restart the Puppet service
    echo "Restarting Puppet service."
    systemctl restart puppet.service

    # Check the status of the Puppet service
    echo "Checking Puppet service status."
    systemctl status puppet.service

    echo "Script completed successfully."
fi
