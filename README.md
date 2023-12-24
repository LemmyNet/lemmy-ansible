# Lemmy-Ansible

This provides an easy way to install [Lemmy](https://github.com/LemmyNet/lemmy) on any server. It automatically sets up an nginx server, letsencrypt certificates, docker containers, pict-rs, and email smtp.

## Requirements

To run this ansible playbook, you need to:

- Have a Debian/AlmaLinux 9-based server / VPS where lemmy will run.
- Supported CPU architectures are x86-64 and ARM64.
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

### Upgrading to 1.3.1 (Lemmy 0.19.1)

This is a very minor release but fixes issues relating to federation as part of the Lemmy update.

#### Steps

- `git pull && git checkout 1.3.1`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.3.0 (Lemmy 0.19.0 & pictrs-0.4.7)

This is a major change and has required reading! tl;dr

- Lemmy has been upgraded to 0.19.0
- pict-rs has been upgraded to 0.4.7
  - pict-rs has not been integrated with postgres yet
- "Optional Modules" are now available to be added to your lemmy install as provided by the community.
  - The first being pictrs-safety

#### Steps

- Prepare to have downtime as the database needs to perform migrations!
- Run `git pull && git checkout 1.3.0`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`
- Lemmy will now be down! In testing this takes from 20 to 60 minutes.
  - If you are bored you can ssh into your server, and check the logs on postgres for updates
  - `docker compose logs -f postgres` while ssh'd and in your Lemmy directory

#### Update your pict-rs sled-database (Optional)

If you are happy for pict-rs to be down _for a while_ ~go straight to our `1.3.1` git tag which updates pictrs to 0.5.0~. Otherwise keep reading.
Starting with 0.5.0 your database will automatically upgrade to the latest version, which will cause downtime for your users.
As such there is an intermediary step where you can upgrade your database in the background to prepare for 0.5 (Reference documentation)[https://git.asonix.dog/asonix/pict-rs/releases#user-content-upgrade-preparation-endpoint]. This ensure no-one is caught out by unforseen downtime of multiple services.

Once you have deployed lemmy-ansible `1.3.0` tag, please continue (if you want):

- Take note of what your pict-rs API Key is under `vars.yml`
- Take note of what your docker network name is. (It's normally the domain without any extra characters)
  - You should be able to find it via: `docker network ls | grep _default` if in doubt.
- Run the following command replacing `api-key` with the pict-rs api key, & `youdomain` with the network name.
- `docker run --network yourdomain_default --rm curlimages/curl:8.5.0 --silent -XPOST -H'X-Api-Token: api-key' 'http://pictrs:8080/internal/prepare_upgrade'`
- This will start the background process updating your database from 0.4 to 0.5 compatible.

This is only Optional, and takes a shorter amount of time than the Lemmy database upgrade, but on huge installations it may take a lot longer.

#### Optional Module(s)

Our first optional module is [pictrs-safety](https://github.com/db0/pictrs-safety). See the repo linked for more information, especially for integration with pictrs (which is what it is for) Thanks to @db0 for their contribution.  
See the `pictrs_safety_env_vars` under `examples/vars.yml` for relevant options (and the two password variables)  
To enable this module to be used you must ADD `pictrs_safety: true` to your `vars.yml`.

### Upgrading to 1.2.1 (Lemmy 0.18.5)

This is a minor change which fixes the issue with the Postgres container not using the `customPostgres.conf` file.

#### Steps

- Please regenerate your `customPostgres.conf` from `examples/customPostgres.conf`
- **OR**
- Add the following block to your current customPostgres file.

```
# Listen beyond localhost
listen_addresses = '*'
```

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
