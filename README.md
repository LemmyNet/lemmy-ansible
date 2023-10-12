# Lemmy-Ansible

This provides an easy way to install [Lemmy](https://github.com/LemmyNet/lemmy) on any server. It automatically sets up an nginx server, letsencrypt certificates, docker containers, pict-rs, and email smtp.

## Requirements

To run this ansible playbook, you need to:

- Have a Debian/AlmaLinux 9-based server / VPS where lemmy will run.
- Configure a DNS `A` Record to point at your server's IP address.
- Make sure you can ssh to it, with a sudo user: `ssh <your-user>@<your-domain>`
- Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (>= `2.11.0` on your **local** machine (do not install it on your destination server).

### Supported Distribution Playbook Matrix

These are the distributions we currently support. Anything not listed here is currently not supported.  
If you wish to see another distribution on the list, please test on the latest commit in `main` and report your findings via an Issue.

| Distribution | Version   | Playbook              |
| ------------ | --------- | --------------------- |
| Debian       | 10        | `lemmy.yml`           |
| Debian       | 11        | `lemmy.yml`           |
| Debian       | 12        | `lemmy.yml`           |
| Ubuntu       | 22.04 LTS | `lemmy.yml`           |
| RHEL         | 9         | `lemmy-almalinux.yml` |

## Install

1. Clone this repo & checkout latest tag

   ```
   git clone https://github.com/LemmyNet/lemmy-ansible.git
   cd lemmy-ansible
   git checkout $(git describe --tags)
   ```

2. Make a directory to hold your config:

   `mkdir -p inventory/host_vars/<your-domain>`

3. Copy the sample configuration file:

   `cp examples/config.hjson inventory/host_vars/<your-domain>/config.hjson`

   Edit that file and change the config to your liking. Note: **Do not edit anything inside the {{ }} braces.**

   [Here are all the config options.](https://join-lemmy.org/docs/en/administration/configuration.html#full-config-with-default-values)

4. Copy the sample inventory hosts file:

   `cp examples/hosts inventory/hosts`

   Edit the inventory hosts file (inventory/hosts) to your liking.

5. Copy the sample postgresql.conf

   `cp examples/customPostgresql.conf inventory/host_vars/<your-domain>/customPostgresql.conf`

   You can use [the PGTune tool](https://pgtune.leopard.in.ua) to tune your postgres to meet your server memory and CPU.

6. Copy the sample `vars.yml` file

   `cp examples/vars.yml inventory/host_vars/<your-domain>/vars.yml`

   Edit the `inventory/host_vars/<your-domain>/vars.yml` file to your liking.

7. Run the playbook:

   _Note_: See the "Supported Distribution Playbook Matrix" section above if you should use `lemmy.yml` or not

   `ansible-playbook -i inventory/hosts lemmy.yml`

   _Note_: if you are not the root user or don't have password-less sudo, use this command:

   `ansible-playbook -i inventory/hosts lemmy.yml --become --ask-become-pass`

   _Note_: if you haven't set up ssh keys[^1], and ssh using a password, use the command:

   `ansible-playbook -i inventory/hosts lemmy.yml --become --ask-pass --ask-become-pass`

   [Full ansible command-line docs](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html)

   If the command above fails, you may need to comment out this line In the ansible.cfg file:

   `interpreter_python=/usr/bin/python3`

[^1]: To create an ssh key pair with your host environment, you can follow the [instructions here](https://www.ssh.com/academy/ssh/keygen#copying-the-public-key-to-the-server), and then copy the key to your host server.

## Upgrading

Since version `1.1.0` we no longer default to using `main` but use tags to make sure deployments are versioned.
With every new release all migration steps shall be written below so make sure you check out the [Lemmy Releases Changelog](https://github.com/LemmyNet/lemmy/blob/main/RELEASES.md) to see if there are any config changes with the releases since your last read.

### Upgrading to 1.2.0 (Lemmy 0.18.5)

Major changes:

- All variables are not under a singular file so you will not need to modify anything: `inventory/host_vars/{{ domain }}/vars.yml`
- `--become` is now optional instead of forced on

#### Steps

- Run `git pull && git checkout 1.2.0`
- When upgrading from older versions of these playbooks, you will need to do the following:
  - Rename `inventory/host_vars/{{ domain }}/passwords/postgres` file to `inventory/host_vars/{{ domain }}/passwords/postgres.psk`
  - Copy the `examples/vars.yml` file to `inventory/host_vars/{{ domain }}/vars.yml`
  - Edit your variables as desired
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.1.0 (Lemmy 0.18.3)

- No major changes should be required

## Migrating your existing install to use this deploy

- [Follow this guide](https://join-lemmy.org/docs/en/administration/backup_and_restore.html) to backup your existing install.
- Run `docker-compose stop` to stop lemmy.
- Move your docker folders on the server to `<lemmy_base_dir>/<your-domain>`.
- Copy your postgres password to `inventory/host_vars/<your-domain>/passwords/postgres`.
- Follow the install guide above, making sure your `config.hjson` is the same as your backup.

## Uninstall

`ansible-playbook -i inventory/hosts uninstall.yml --become`

## License

- [AGPL License](/LICENSE)
