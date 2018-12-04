This is a [Vagrant](https://www.vagrantup.com/) Environment for a IPsec VPN device based on [strongSwan](https://strongswan.org).

These are the machines and how they are connected with each other:

<img src="diagram.png">


# Usage

Build and install the [Ubuntu Base Box](https://github.com/rgl/ubuntu-vagrant).

Run `vagrant up` to launch everything.

Login into the moon machine (a VPN device), and watch the network traffic:

    tcpdump -n -i any tcp port 3000

From your host computer, access the following URLs to see them working:

    http://10.1.0.4:3000
    http://10.2.0.4:3000

Then, ssh into the moon-ubuntu machine, and try it there:

    vagrant ssh moon-ubuntu
    wget -qO- 10.2.0.4:3000


# Reference

* https://wiki.strongswan.org/projects/strongswan/wiki/IntroductionTostrongSwan
