# Upgrading

This file shows all steps in how to upgrade between "versions" of the lemmy-ansible repository.

While we specify a version of Lemmy, pict-rs, postgres, etc. at the point in time we make a release, it does not mean that you cannot mix-and-match versions. (ie; you can run pictrs 0.5.10 with Lemmy 0.19.3).

While you are not forced into running the specific versions, we do not go through thorough testing on all version compatibility matrices, so please make your best judgement and always backup before performing updates.

### Upgrading to 1.5.6 (Lemmy 0.19.10)

#### Steps

- `git pull && git checkout 1.5.6`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.5 (Lemmy 0.19.9)

#### Steps

- `git pull && git checkout 1.5.5`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.4 (Lemmy 0.19.8)

#### Steps

- `git pull && git checkout 1.5.4`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.3 (Lemmy 0.19.7)

#### Steps

- `git pull && git checkout 1.5.3`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.2 (Lemmy 0.19.6)

#### Steps

- `git pull && git checkout 1.5.2`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.1 (Lemmy 0.19.5)

#### Steps

- `git pull && git checkout 1.5.1`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.5.0 (Lemmy 0.19.4, Pict-rs 0.5, postgres 16)

> **DO NOT RUN IT WITHOUT READING THIS WHOLE SECTION**

This is a major release which requires you to update postgres to v16, and pictrs to v0.5. Once that is done proceed with your regular deployments.

#### Postgres Upgrade from v15 to v16

You need to migrate from postgres v15 to v16. A helper script is provided, that dumps your database, swaps postgres container versions, starts them, and then imports the backup into the new container.

There will be downtime, and it is a little scary as it will be deleting the `volumes/postgres` folder. The only backup you have during this time will be the `15_16_dump.sql`, created by the helper script.

On my reference instance (4 CPU, 8GB Memory, 30GB volumes/postgres), it took 10 minutes to dump the backup, and another 20 minutes to import it again. The biggest time sink when importing is when it recreates the indexes.
If you have a faster system and no noisy neighbours you could get the dump and import to be below 20 minutes, but I'd aim for a 60 minute maintenace window.

- The script you need to download and push onto your server: [postgres_15_to_16_upgrade.sh](https://github.com/LemmyNet/lemmy/blob/main/scripts/postgres_15_to_16_upgrade.sh).

```
# Go to your lemmy directory with the docker-compose.yml
cd /srv/lemmy/{my_lemmy_domain}/

# Download the upgrade script
sudo wget -O postgres_15_to_16_upgrade.sh "https://raw.githubusercontent.com/LemmyNet/lemmy/main/scripts/postgres_15_to_16_upgrade.sh"

# Run the script. Be aware that it may take > 20 minutes
sudo sh postgres_15_to_16_upgrade.sh
```

- This also creates a backup file of your old database, called `15_16_dump.sql`. **Do not delete this file** until you are sure that everything is working correctly, for at least a few days.

#### Pictrs 0.4 -> 0.5 Upgrade

`0.19.4` also adds functionality only supported by pictrs version `0.5`. Follow the [v0.4 -> v0.5 migration guide](https://git.asonix.dog/asonix/pict-rs.git#0-4-to-0-5-migration-guide) to make sure that your pictrs env vars in `vars.yml` are correct.

There are more detailed pictrs upgrade instructions below.

#### Steps

- `git checkout main && git pull && git checkout 1.5.0`
- Check the diff between the two versions to see the changes our examples:
  - examples/customPostgresql.conf: We added a new autoexplain & stats feature, & enabled jit after v16 upgrade. \
    - On low memory systems, you might want to disable jit still: `jit=0`
  - examples/hosts: Add `lemmy_web_port` to have a dedicated port
  - examples/vars.yml: Add `postgres_shm` to have the correct shared memory for postgres
- Confirm you are already running Postgres v16
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.4.0 (Lemmy 0.19.3 & Pict-rs 0.5.4)

This is a semi-major release which upgrades pict-rs to 0.5 which has support for postgres as a backend. This configuration is **not supported** by lemmy-ansible for the moment.

#### Steps

- `git pull && git checkout 1.4.0`
- Read [Pictrs' Configuration Changes](https://git.asonix.dog/asonix/pict-rs/#configuration-updates)
- Amend your `vars.yml` file to respect the new changes
  - Optional: Add: `PICTRS__UPGRADE__CONCURRENCY` with a value between 32 and 512 depending on how much RAM/CPU you want to dedicate to the upgrade process. A value of 32 used about 2.5GB of RAM for the migration.
  - Optional: Curl `/internal/prepare_upgrade` to minimise downtime while upgrading. See [the instructions below](https://github.com/LemmyNet/lemmy-ansible#update-your-pict-rs-sled-database-optional) or the official documentation [here](https://git.asonix.dog/asonix/pict-rs/releases#user-content-upgrade-preparation-endpoint)
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.3.1 (Lemmy 0.19.1)

This is a very minor release but fixes issues relating to federation as part of the Lemmy update.

#### Steps

- `git pull && git checkout 1.3.1`
- Run your regular deployment. Example: `ansible-playbook -i inventory/hosts lemmy.yml --become`

### Upgrading to 1.3.0 (Lemmy 0.19.0 & Pict-rs 0.4.7)

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

listen_addresses = '\*'

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
