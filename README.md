# Example MySQL live migration

This project is to show an example of how to migrate a MySQL database from one
instance to another.  A common scenario is migrating a database from one remote
machine to another remote machine.

Prerequisites:

* 16GB of system memory.
* Running on a computer which has `bash`, `mysql`, and `mysqldump` commands
  available (essentially bash and MySQL client only).
* [Vagrant][vagrant] for provisioning example database servers.  Vagrant depends
  on [VirtualBox][vbox].

This example uses dummy MySQL data from [`datacharmer/test_db`][test_db].

# Overview

The overview of a live MySQL migration process is:

1. On the source and destination database servers create a `datasync` database
   user which is capable of authenticating remotely with the database.  The user
   also needs all privileges granted on the database to be migrated.
2. Set [`mysql-migrate.sh`](mysql-migrate.sh) environment variables for both the
   source and destination database servers.  This is required to properly
   connect and authenticate with the source and destination database servers.
3. Execute `mysql-migrate.sh`.

# mysql-migrate.sh environment variables

`mysql-migrate.sh` script can have several environment variables set to
customize its behavior.  The default variables are to simplify running examples
in this repository.

Source database server vars:

* `SRC_DB_HOST` - hostname (default: `127.0.0.1`)
* `SRC_DB_PORT` - port of the MySQL service (default: `3333`)
* `SRC_DB_USER` - username of database user (default: `datasync`)
* `SRC_DB_PASSWORD` - password of database user (default: `syncpw`)
* `SRC_DB_DATABASE` - (default: `employees`)

Destination database server vars:

* `DST_DB_HOST` - hostname (default: `127.0.0.1`)
* `DST_DB_PORT` - port of the MySQL service (default: `3334`)
* `DST_DB_USER` - username of database user (default: `datasync`)
* `DST_DB_PASSWORD` - password of database user (default: `syncpw`)

> **WARNING:** `SRC_DB_PORT` and `DST_DB_PORT` are not default to 3306 which is
> the typical MySQL port.  Be aware of this.  Don't use any example passwords in
> this repository to create accounts on active database servers.

# Run the example migration

Set up your database servers.  Execute:

    vagrant up

`vagrant up` will provision two database servers (`src_db` and `dst_db`) based
on the [`Vagrantfile`](Vagrantfile).  This will set up both database servers
with a MySQL service and creating the `datasync` database user on both servers.
It will also populate the `src_db` service with [dummy MySQL data][test_db] for
running the example migration.

Perform the migration.  Execute:

    mysql-migrate.sh

The above command will dump from the source database and import the dump to the
destination database.

> **Tip:** Before migrating, inspect both the source and destination database
> servers.

# Other helpful commands

Log into the source database server.

    vagrant ssh src_db

Log into the destination database server.

    vagrant ssh dst_db

You can log into the database directly from the database servers if you run
`mysql` as the `root` user.

    sudo mysql

Alternatively, connect to the destination database remotely using a local
`mysql` command.

    mysql -h 127.0.0.1 -P 3334 -u datasync -psyncpw

[test_db]: https://github.com/datacharmer/test_db
[vagrant]: https://www.vagrantup.com/
[vbox]: https://www.virtualbox.org/
