Vagrant.configure("2") do |config|
  config.vm.box = "fedora/32-cloud-base"
  config.vm.provider :libvirt do |domain|
    domain.cpus = 4
    domain.memory = 16384
    domain.machine_virtual_size = 100
  end
  config.vm.define :vagrant_crc do |vagrant_host|
    vagrant_host.vm.hostname = "vagrant-crc.fishjump.com"

    # you need a publicly addressable ip to access crc remotely
    # this will create one in addition to the private one
    # the macvtap address won't be addressable from the host, that's why
    # you need two
    vagrant_host.vm.network "public_network", dev: "eno1", mode: "bridge"

    #take advantage of our new disk size
    vagrant_host.vm.provision "shell", privileged: true, inline: \
      "echo -e \"yes\n100%\" | parted /dev/vda ---pretend-input-tty unit % resizepart 1 "
    vagrant_host.vm.provision "shell", privileged: true, inline: \
      "resize2fs /dev/vda1"

    #prepare for attaching from remote
    vagrant_host.vm.provision "file", source: "./configure-remote.sh", destination: "configure-remote.sh"
    vagrant_host.vm.provision "file", source: "./configure-remote-priv.sh", destination: "configure-remote-priv.sh"
    vagrant_host.vm.provision "shell", privileged: false, inline: \
      "chmod u+x ~/configure-remote.sh ~/configure-remote-priv.sh"

    #get crc going
    vagrant_host.vm.provision "file", source: "./pull-secret", destination: "pull-secret"
    vagrant_host.vm.provision "file", source: "./setup-run-crc.sh", destination: "setup-run-crc.sh"
    vagrant_host.vm.provision "shell", privileged: false, inline: \
      "chmod u+x ~/setup-run-crc.sh"
    vagrant_host.vm.provision "shell", privileged: false, inline: \
      "~/setup-run-crc.sh"

#    vagrant_host.vm.provision "shell", privileged: false, inline: \
#      "sudo -E ~/configure-remote.sh"


  end
end


