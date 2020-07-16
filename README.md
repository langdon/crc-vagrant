# crc-vagrant
A set of files to use with Vagrant to install and make CodeReady Containers available (https://developers.redhat.com/products/codeready-containers/overview)

Unfortunately, using this isn't quite as simple as `vagrant up`.
However, it isn't that hard and should be idempotent on multiple `vagrant up`s.
Please read on!

## Pre-requisites

First off, this README assumes Fedora.
However, it should be pretty close for any Vagrant platform.
You just may have to tweak some settings.
I'll try to identify where as we go.

Next make sure you have KVM and nested KVM-enabled.
On Fedora, there is a nice [guide](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/).
Your mileage may vary on how exactly to enable this using other virtualization tools (e.g. virtualbox, vmware).

OK, now make sure you have enough RAM, cpu, and disk for the requirements.
The RAM and cpu are hard requirements but the disk is thinly provisioned and will use about 30Gs after the install is complete.
You can modify these settings at the top of the `Vagrantfile` if you need to.

Fedora also has an annoying thing where the name of your NICs are not gauranteed.
As a result, you need to confirm that your server has a NIC called "eno1" which is the one you want your CodeReady Continaers instance to listen on.
You can confirm this on a command line with `ip a` and look for the name of the NIC.
If you have a different name, change the "dev" attribute on the "public_network" directive in the `Vagrantfile`.

If you are running this `Vagrantfile` on the computer your are directly accessing (the one you will be running a web browser in or `oc` from), you need remove the `public_network` altogther.
As the `public_network` is using macvtap to create the interface, the IP is not directly available from the host.
If you want more details about macvtap and why you can't access those IPs, see Scott Lowe's [blog post](https://blog.scottlowe.org/2016/02/09/using-kvm-libvirt-macvtap-interfaces/) or the [libvirt  documentation](https://libvirt.org/formatdomain.html#elementsNICSDirect).

Finally, you need to go get your "pull secret" by following the [CodeReady Containers Install Instructions](https://cloud.redhat.com/openshift/install/crc/installer-provisioned).  Once you get the secret, put it in a file called "pull-secret" in the same directory as the `Vagrantfile` (and shell scripts).

## Launch

Once you have that stuff out of the way, you can launch the Vagrant image with `vagrant up`.
The `vagrant up` process will take a bit of time and, unfortunately, crc will probably not be up by the time it is done.
The `Vagrantfile` fires off a couple jobs in the background so the VM can come up even if crc isn't finished.
If you watch the output log at the end of the `vagrant up`, you will see a couple log files to monitor either in the VM or outside it.

```
    vagrant_crc: running crc start in the background
    vagrant_crc: crc start is running in a tmux session in the vagrant VM.  You can check its status with vagrant ssh -c "tail -f ~/crc-start.log"
    vagrant_crc: Running remote-config setup in background
    vagrant_crc: Remote config shell script is running in a tmux session in the vagrant VM. You can check its status with vagrant ssh -c "tail -f ~/remote-config.log"
    vagrant_crc: When everything is complete, please see ~/remote-config.log for instructions on configuring your host DNS
```

Once you see those both complete, you need to configure your host's DNS to find the CRC inside the Vagrant VM.
Instructions for how to do this will be at the end of the `remote-config.log` on the Vagrant guest.
However, in simple terms, you need to copy the generated `00-use-dnsmasq.conf` and `01-crc.conf` out of the VM and into `/etc/NetworkManager/conf.d` and `/etc/NetworkManager/dnsmasq.d` (respectively) and `systemctl reload NetworkManager`.

Once you have all that done, you should be able to access CRC via a web browser at `https://console-openshift-console.apps-crc.testing` but, you may want to check `crc console`'s output in case something has changed.
The `oc` client should work too, using `https://api.crc.testing:6443`.
However, check the `console` output in case that is any different as well.

From here, [`crc` docs](https://access.redhat.com/documentation/en-us/red_hat_codeready_containers/1.11/) and [`oc` docs](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/cli_tools/index) can take over, just remember that you have `crc` inside the guest VM and you want to use `oc` or a web browser from a remote machine to interact with CRC (aka OpenShift).

Please leave comments, issues, etc on this repo.
Also, a huge shout out to Jason Dobies ([@jdob](https://twitter.com/jdob)) and his "[Accessing CodeReady Containers on a Remote Server](https://www.openshift.com/blog/accessing-codeready-containers-on-a-remote-server/)" blog post and his upstream ;) [Trevor McKay's](https://github.com/tmckayus) [gist](https://gist.github.com/tmckayus/8e843f90c44ac841d0673434c7de0c6a) which I derived all the hard bits from.
