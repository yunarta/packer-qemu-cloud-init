    #!/bin/bash -l
set -ex

# This function downloads a puppet installation script from a server
# -k or --insecure allows curl to perform "insecure" SSL connections and transfers
# Saving the file as /tmp/install.bash
download_script() {
    echo "Starting to download puppet installation script."
    curl -k https://puppet.sg.singtelgroup.net:8140/packages/current/install.bash -o /tmp/install.bash
}

# This function attempts to install Puppet by running the downloaded script, till it is successful or till timeout
wait_for_puppet_install() {

  # Capture the start time of the function
  start_time=$(date +%s)
  # Define a timeout in seconds (5 minutes or 300 seconds)
  timeout=300

  # Loop till the script succeeds or till a timeout condition is achieved
  while true; do
      # Execute installation script in a child shell to avoid exiting the script in case of an error
      set +e
      echo "Attempting to run installation script."
      bash /tmp/install.bash $@

      # Capture the exit code
      exit_code=$?
      set -e

      # Calculate the elapsed time
      current_time=$(date +%s)
      elapsed_time=$((current_time - start_time))

      # If puppet installation succeeded or the elapsed time is greater than timeout, exit the loop
      if [[ $exit_code -ne 1 ]]; then
          echo "Exiting: Command succeeded or failed with a non-retryable exit code."
          break
      fi
      if [[ $elapsed_time -ge $timeout ]]; then
          echo "Exiting: Timeout of $timeout seconds reached."
          break
      fi

      # If the Puppet installation failed, sleep for a short period before retrying the installation
      echo "Installation failed, retrying after 5 seconds."
      sleep 5
  done

  # Return the exit code to be used in later steps for processing
  return $exit_code
}

echo "Beginning Puppet installation."
download_script
wait_for_puppet_install $@

sed -i '2i\runtimeout = 4h' /etc/puppetlabs/puppet/puppet.conf