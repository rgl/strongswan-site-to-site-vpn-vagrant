# to make sure the nodes are created in order we
# have to force a --no-parallel execution.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

suffix = 'vpn.example.com'
config_moon_fqdn        = "moon.#{suffix}"
config_moon_ip          = '192.168.0.10'
config_moon_internal_ip = '10.1.0.2'
config_moon_ubuntu_fqdn = "moon-ubuntu.#{config_moon_fqdn}"
config_moon_ubuntu_ip   = '10.1.0.4'
config_sun_fqdn         = "sun.#{suffix}"
config_sun_ip           = '192.168.0.20'
config_sun_internal_ip  = '10.2.0.2'
config_sun_ubuntu_fqdn  = "sun-ubuntu.#{config_sun_fqdn}"
config_sun_ubuntu_ip    = '10.2.0.4'

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-18.04-amd64'

  config.vm.provider :libvirt do |lv, config|
    lv.memory = 512
    lv.cpus = 2
    lv.cpu_mode = 'host-passthrough'
    # lv.nested = true
    lv.keymap = 'pt'
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  end

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = true
    vb.memory = 512
    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end

  config.vm.define 'moon' do |config|
    config.vm.hostname = config_moon_fqdn
    config.vm.network :private_network, ip: config_moon_ip, libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.network :private_network, ip: config_moon_internal_ip, netmask: '255.255.0.0', libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, inline: "echo '#{config_moon_ip} #{config_moon_fqdn}' >>/etc/hosts"
    config.vm.provision :shell, inline: "echo '#{config_sun_ip} #{config_sun_fqdn}' >>/etc/hosts"
    config.vm.provision :shell, path: 'provision-common.sh'
    config.vm.provision :shell, path: 'provision-certificates.sh'
    config.vm.provision :shell, path: 'provision-vpn-device.sh'
  end

  config.vm.define 'sun' do |config|
    config.vm.hostname = config_sun_fqdn
    config.vm.network :private_network, ip: config_sun_ip, libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.network :private_network, ip: config_sun_internal_ip, netmask: '255.255.0.0', libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, inline: "echo '#{config_moon_ip} #{config_moon_fqdn}' >>/etc/hosts"
    config.vm.provision :shell, inline: "echo '#{config_sun_ip} #{config_sun_fqdn}' >>/etc/hosts"
    config.vm.provision :shell, path: 'provision-common.sh'
    config.vm.provision :shell, path: 'provision-vpn-device.sh'
  end

  config.vm.define 'moon-ubuntu' do |config|
    config.vm.hostname = config_moon_ubuntu_fqdn
    config.vm.network :private_network, ip: config_moon_ubuntu_ip, netmask: '255.255.0.0', libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, path: 'provision-common.sh'
    config.vm.provision :shell, path: 'provision-ubuntu.sh'
  end

  config.vm.define 'sun-ubuntu' do |config|
    config.vm.hostname = config_sun_ubuntu_fqdn
    config.vm.network :private_network, ip: config_sun_ubuntu_ip, netmask: '255.255.0.0', libvirt__forward_mode: 'route', libvirt__dhcp_enabled: false
    config.vm.provision :shell, path: 'provision-common.sh'
    config.vm.provision :shell, path: 'provision-ubuntu.sh'
  end
end
