# JMeter in Server Mode

Forked since I needed jmeter 3.1 slaves.

[![](https://badge.imagelayers.io/hhcordero/docker-jmeter-server:latest.svg)](https://imagelayers.io/?images=hhcordero/docker-jmeter-server:latest 'Get your own badge on imagelayers.io')

### Supported Tags

- [`latest`](https://github.com/hhcordero/docker-jmeter-server/tree/master/alpine)
- [`alpine`](https://github.com/hhcordero/docker-jmeter-server/tree/master/alpine)
- [`ubuntu`](https://github.com/hhcordero/docker-jmeter-server)

Docker image for JMeter in server mode running Minimal Alpine Linux or Ubuntu. Make sure to open port 1099. You also need the public ip (see environment variable 'IP' below).

### Usage

On cli, execute the following:

```sh
$   docker run \
		--detach \
		--publish 1099:1099 \
		--env "IP=$PUBLIC_IP" \
		--name jmeter-server \
		hirro/docker-jmeter-server
```

### Helper script

[Dockerized JMeter - A Distributed Load Testing Workflow](https://gist.github.com/hhcordero/abd1dcaf6654cfe51d0b)

This is a shell script that make use of [Docker Machine](https://github.com/docker/machine) to provision VM. Currently supported clouds are:
- Amazon
- DigitalOcean


### Ansible scripts

	ansible-playbook -i ./hosts.ini playbook.yml

#### playbook.yml

```sh
- hosts: jmeter-slaves
  become: yes
  become_method: sudo
  tasks:
    - name: Information
      debug:
        msg: "Using IP {{ public_ip }}"

    - name: Create conf directory
      file: path=/opt/jmeter-server state=directory  

    - name: Copy users.csv to hosts
      copy: src=users.csv dest=/opt/jmeter-server/users.csv mode="u+r"

    - name: Start jmeter container
      docker_container:
        name: "jmeter-server"
        image: "hirro/docker-jmeter-server"
        restart_policy: unless-stopped    
        memory: 2G
        ports:
          - "1099:1099"
        volumes:
          - /opt/jmeter-server/users.csv:/usr/local/apache-jmeter-3.1/users.csv
        env:
          IP: "{{ public_ip }}"
```



#### hosts.ini

```ini
[jmeter-slaves]
host1 public_ip=192.168.1.21
host2 public_ip=192.168.1.22
host3 public_ip=192.168.1.23
```

