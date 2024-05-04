This is a [Vagrant](https://www.vagrantup.com/) Environment for a IPsec VPN device based on [strongSwan](https://strongswan.org).

These are the machines and how they are connected with each other:

<img src="diagram.png">


# Usage

Build and install the [Ubuntu Base Box](https://github.com/rgl/ubuntu-vagrant).

Launch the environment:

```bash
vagrant up --no-destroy-on-error
```

Login into the `moon` machine (a VPN device), and watch the network traffic:

```bash
vagrant ssh moon # moon (10.1.0.2)
tcpdump -n -i any tcp port 3000
```

From your host computer, access the following URLs to see them working:

    http://10.1.0.4:3000
    http://10.2.0.4:3000

Then, ssh into the `moon-ubuntu` machine (`10.1.0.4`), and try accessing
the `sun-ubuntu` machine (`10.2.0.4`):

```bash
vagrant ssh moon-ubuntu # moon-ubuntu (10.1.0.4)
wget -qO- 10.2.0.4:3000 # sun-ubuntu (10.2.0.4)
```


# Reference

* https://wiki.strongswan.org/projects/strongswan/wiki/IntroductionTostrongSwan
