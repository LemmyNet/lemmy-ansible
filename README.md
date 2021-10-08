# Lemmy-Docker-Ansible-Deploy

This provides an easy way to install [Lemmy](https://github.com/LemmyNet/lemmy) on any server.

## Requirements

To run this playbook, you need to:

- Have a server / VPS where lemmy will run.
- Configure a DNS `A` Record to point at your server's IP address.
- Make sure you can ssh to it: `ssh my_user@domain.tld`
- Install [Ansible](https://www.ansible.com/) on your local machine.


## Deploy steps

Run the following commands:


Clone lemmy-docker-ansible-deploy: 

```
git clone https://github.com/LemmyNet/lemmy-docker-ansible-deploy.git
cd lemmy-docker-ansible-deploy
```

Make a directory to hold your config: 

`mkdir inventory/host_vars/<your-domain>`

Copy the sample configuration file:

`cp examples/config.hjson inventory/host_vars/<your-domain>/config.hjson`

Edit that file and change the config to your liking.

Copy the sample inventory hosts file:

`cp examples/hosts inventory/hosts`

Edit the inventory hosts file (inventory/hosts) to your liking.

Run the playbook: 

`ansible-playbook -i inventory/hosts lemmy.yml --become`

If the command above fails, you may need to comment out this line In the ansible.cfg file:

`interpreter_python=/usr/bin/python3`
