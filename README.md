# phpbb-static-mirror-generator

A docker-based sandbox for creating an offline static archive of an old phpBB forum.

This project contains three docker containers, a database, webserver, and crawler.

The database starts up, imports a database, the webserver serves phpBB 3 with the proper system
libraries, and apache mods installed for phpBB 3, specifically version `3.0.6` which was the target
version for this project to generate a static archive of the alientrap forums. Forums which housed a
wealth of data around Nexuiz and its history, the predecessor to Xonotic.


# Requirements

 - docker
 - docker-compose
 - A database phpbb3 database dump.


# Configuration

This repository uses phpBB 3.0.6 to match the received database dump. 

Database dump provided by Willis with the blessing of Lee Vermeulen

```
e75c0762c0adade560719beba630f69db39616e89e58bd898ad3e76e4f4b4849  phpBB-3.0.6.zip
```

https://download.phpbb.com/pub/release/3.0/3.0.6/phpBB-3.0.6.zip

The crawler has an initial sleep time, you might want to modify this in `.env`


### If you wish to configure this yourself

You'll need to modify at minimum:

```
config/config.php
.env
docker/containers/apache/sites-available/<your-vhost-here>
data-initdb.d/<your-db-dump-here>
```

I might not have exposed all configuration options.  Massage for your needs,
`docker/containers/apache.Dockerfile`.


## Usage

```
docker-compose up
```

To view the forums on the docker host, add an entry to your `/etc/hosts` file:

Example:

```
127.0.0.1       forums.alientrap.local
```

Access, the web-frontend on port 8080, e.g. http://forums.alientrap.local:8080


# Project Structure

```
.
├── archived                                # static mirrors go here (gets created)
├── config                                  # forum config
├── data                                    # database filesystem (gets created)
├── docker                                  # docker assets
└── data-initdb.d                           # forum dumps
```

# Advice

This code is intended for crawling locally, in the sandbox.  Do not use the mirror script outside
the sandbox, without modifications, unless you intend to get yourself autobanned from forums that
don't appreciate being crawled aggressively.

I used `sed` to renamespace the forums data.  Your local vhost name for the forums needs to match
in your forum's database for the cookies to work.  If your cookies aren't setting, try clearing the
forum cache.

```
sed -i "s#alientrap.org/forums#forums.alientrap.local#g; \
        s#alientrap.org#forums.alientrap.local#g; \
        s#'cookie_domain','forums.alientrap.local'#'cookie_domain','alientrap.local'#g" 00-alientrap_phpbb3_configured.sql
```

You can open a shell on a container with the following command:

```
docker-compose exec <container_name> /bin/bash
```

Containers are described in `docker-compose.yml`.  They are `db`, `apache`, `crawler`.

For example:

```
docker-compose exec db /bin/bash
```

On the db container, you can use mysql/mysqladmin, etc.

For example:

```
docker-compose exec db /bin/bash             # open shell
mysql -u forums -pforums forums              # open mysql
SHOW TABLES;                                 # look at the tables
# censor IP addresses
UPDATE phpbb_users SET user_ip="127.0.0.1";
UPDATE phpbb_log SET log_ip="127.0.0.1";
UPDATE phpbb_posts SET poster_ip="127.0.0.1";
UPDATE phpbb_poll_votes SET vote_user_ip="127.0.0.1";
UPDATE phpbb_sessions SET session_ip="127.0.0.1";
UPDATE phpbb_bots SET bot_ip="127.0.0.1";
```

# License

MIT

# Credits

 - Willis for recovering a database dump
 - Lee for allowing this data to be public

