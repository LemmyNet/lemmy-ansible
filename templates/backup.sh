#!/bin/bash

domain='{{ domain }}'
backup_path='/dump'
dump=${domain}_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql

cd /opt/lemmy/{{ domain }} &&\
    docker compose exec -T postgres pg_dump -c -U lemmy \
        --format=custom --file ${backup_path}/${dump}

