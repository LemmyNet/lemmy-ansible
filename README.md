# Lemmy-Ansible

This provides an easy way to install [Lemmy](https://github.com/LemmyNet/lemmy) on any server. It automatically sets up an nginx server, letsencrypt certificates, and email.

## Requirements

To run this ansible playbook, you need to:

- Have a server / VPS where lemmy will run.
- Configure a DNS `A` Record to point at your server's IP address.
- Make sure you can ssh to it: `ssh <your-user>@<your-domain>`
- Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your local machine.<br><br>
Can be ingnored if you are using another web server:
- Install [NGINX](http://nginx.org/en/download.html) | Linux Install Instruction: [https://nginx.org/en/linux_packages.html](https://nginx.org/en/linux_packages.html)
- Install the Python NGINX Plugin for Certbot [`python3-certbot-nginx`](https://packages.debian.org/bullseye/python3-certbot-nginx)

You must also have a user, with home access.
```
adduser --home /home/lemmy lemmy
```
Lemmy's ansible currently requires no password with sudo.
run `visudo` and append the following:
```
lemmy ALL=(ALL) NOPASSWD: ALL
```
Run `ssh-key-gen` on your local laptop and copy the `*.pub` files contents to `/home/lemmy/.ssh/autorized_keys`
also copy the private key ( non-.pub file created with ssh-key-gen ) into `/home/lemmy/.ssh/` directory.<br>
**Optional**: It is also possible to use instead use scp to share the private key `scp {private key} root@{ip-address}:/home/lemmy/.ssh/` replace any variables signified with `{}` ).<br>
**Optional**: You can automatically share the .pub key with ssh-copy-id but it is best to copy the private key manually run [`man ssh-copy-id`](https://linux.die.net/man/1/ssh-copy-id) for more information.

Append the following to `/home/lemmy/.ssh/config` ( the file might not have anything in it yet, this is normal )

```
Host {domain}
  HostName {domain}
  User user
  IdentityFile ~/.ssh/{ssh-key-name}
  IdentitiesOnly yes
```

**Optional**: If not already disabled, it is also recommended to disable non-key/password authentication for SSH.<br>
run `visudo` and change `PasswordAuthentication yes` to `PasswordAuthentication no`

next run:
```
cd /home/lemmy
sudo -i -u lemmy
```

And you are free to move onto the next segment. 

## Install

Clone this repo: 

```
git clone https://github.com/LemmyNet/lemmy-ansible.git
cd lemmy-ansible
```

Make a directory to hold your config: 

`mkdir -p inventory/host_vars/<your-domain>`

Copy the sample configuration file:

`cp examples/config.hjson inventory/host_vars/<your-domain>/config.hjson`

Edit that file and change the config to your liking. [Here are all the config options.](https://join-lemmy.org/docs/en/administration/configuration.html#full-config-with-default-values)

Copy the sample inventory hosts file:

`cp examples/hosts inventory/hosts`

Edit the inventory hosts file (inventory/hosts) to your liking.

Run the playbook: 

`ansible-playbook -i inventory/hosts lemmy.yml --become`

If the command above fails, you may need to comment out this line In the ansible.cfg file:

`interpreter_python=/usr/bin/python3`

## Upgrading

- Run `git pull`
- Check out the [Lemmy Releases Changelog](https://github.com/LemmyNet/lemmy/blob/main/RELEASES.md) to see if there are any config changes with the releases since your last. 
- Run `ansible-playbook -i inventory/hosts lemmy.yml --become`

## Migrating your existing install to use this deploy

- [Follow this guide](https://join-lemmy.org/docs/en/administration/backup_and_restore.html) to backup your existing install.
- Run `docker-compose stop` to stop lemmy.
- Move your docker folders on the server to `<lemmy_base_dir>/<your-domain>`.
- Copy your postgres password to `inventory/host_vars/<your-domain>/passwords/postgres`.
- Follow the install guide above, making sure your `config.hjson` is the same as your backup.

## Uninstall

`ansible-playbook -i inventory/hosts uninstall.yml --become`
