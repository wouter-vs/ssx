# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.define :ssx do |ssx_config|
        ssx_config.vm.box = "Debian81"
        ssx_config.vm.box_url = "http://intracto-git/vagrant/Debian81.box"

        ssx_config.vm.provider "virtualbox" do |v|
            # show a display for easy debugging
            v.gui = false

            # RAM size
            v.memory = 2048

            # Allow symlinks on the shared folder
            v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        end

        # allow external connections to the machine
        #ssx_config.vm.forward_port 80, 8080

        # Shared folder over NFS unless Windows
        if OS.windows?
            ssx_config.vm.synced_folder ".", "/vagrant"
        else
            ssx_config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc' ,'actimeo=2']
        end

        ssx_config.vm.network "private_network", ip: "192.168.33.10"

        # Shell provisioning
        ssx_config.vm.provision :shell, :path => "shell_provisioner/run.sh"
    end
end
