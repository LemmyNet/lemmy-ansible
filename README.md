# Lemmy-Ansible

This provides an easy way to install [Lemmy](https://github.com/LemmyNet/lemmy) on any server.

## Requirements

To run this ansible playbook, you need to:

- Have a server / VPS where lemmy will run.
- Configure a DNS `A` Record to point at your server's IP address.
- Make sure you can ssh to it: `ssh <your-user>@<your-domain>`
- Install [Ansible](https://www.ansible.com/) on your local machine.


## Install

Clone lemmy-docker-ansible-deploy: 

```
git clone https://github.com/LemmyNet/lemmy-ansible.git
cd lemmy-ansible
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

## Migrating your existing install to use this deploy

- Back up your existing docker folder.
- Run `docker-compose stop` to stop lemmy.
- Move your docker folders on the server to `<lemmy_base_dir>/<your-domain>`.
- Copy your postgres password to `passwords/<your-user>@<your-domain>/postgres`.
- Follow the install guide above, making sure your `config.hjson` is the same as your backup.

## Uninstall

`ansible-playbook -i inventory/hosts uninstall.yml --become`
