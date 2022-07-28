---
title: "DBIx::Class::DeploymentHandler: an 80% howto"
date: 2022-07-28
series:
  - Perl
tags:
  - perl
  - databases
  - deployment
---

This post is about how to use
[DBIx::Class::DeploymentHandler](https://metacpan.org/pod/DBIx::Class::DeploymentHandler)
most of the time. It does not explain why you should do it this way; if you need
to know that, I'm sure I will write that post at some point as well.

This module turns your existing
[DBIx::Class](https://metacpan.org/pod/DBIx::Class) data model into either
deployment scripts, or migration scripts, or both[^1]. It does this by turning the
data model into an interim data structure, which is then serialised to YAML and
committed to source control.

[^1]: A **deployment** script takes a blank database and directly installs your
  structure at some version N. A **migration** script takes an existing database
  at version N and runs scripts to turn it into a version bigger than N. The
  easiest thing to maintain is a single deployment script (N=1) and a series of
  migration scripts that only do 1 version step (N → N+1).

Here's a brief overview of the moving parts:

* Your DBIx::Class schema
* A version number on that
* A YAML file for each version of the schema
* An SQL file that deploys your schema at version 1
* An SQL file that turns version n-1 into version n for each version of the
  schema
* A table in your database that tells DeploymentHandler what version the
  database is currently on

That's honestly it; most of DeploymentHandler's documentation is dancing around
the fact it had to be engineered to work with a bazillion edge cases and weird
existing schemas.

Here's how to do it for a new schema. If you want to follow along at home I've
committed each of these steps in a [github
repository](https://github.com/Altreus/deploymenthandler-example) so you can see things
changing.

## 1. Create object

Like this:

```
use My::Schema;
use DBIx::Class::DeploymentHandler;

my $dh = DBIx::Class::DeploymentHandler->new(
    schema => My::Schema->connect( ... ),     # Connection params are your job
);
```

Add a `schema_version` sub to My/Schema.pm, which should simply return `1` at
this point.

It might be tempting to let your `schema_version` return the `$VERSION` of your
schema module. Don't do that; it complicates things. Most `$VERSION` versions
are not integers, and even if they are, you want to be incrementing your schema
version *before* starting work on the new version, while the module version is
usually incremented *afterwards*.

Also, I bet your schema module is not on version 1 right now.

## 2. Prepare installation

```
$dh->prepare_install;
```

This creates sufficient SQL to deploy your database at the current version (1)
and to install the special table I mentioned that tracks versions.

You will notice a directory called `sql`. You should commit all of this.

You'll only need to do this once per project, but you may find yourself needing
to redo it a few times while getting to grips with the tool itself.

## 3. Install

```
$dh->install;
```

This will look for `sql/*/deploy/1`, where the `*` represents whatever database
type you're connected to, and run the SQL files there.

## 4. Do upgrades

If you edit one of your Result classes you will want to prepare an upgrade. To
do this, increment the number in your `schema_version`, and then run
`prepare_deploy`, `prepare_upgrade`, and then `upgrade`.

```
$dh->prepare_deploy;
$dh->prepare_upgrade;
$dh->upgrade;
```

You'll notice that this is incompatible with the `$dh->install` that you already
had in your script. Yes, sorry about that. I don't think there's a feature of
DeploymentHandler that will just connect to the database and pick whatever is
needed; you'll have to control your script from the command line.

## 5. Sack off that script and use App::DH

Luckily KENTNL (GNU[^2]) wrote a simple way of doing it. Simply install App::DH and
copy the [example
script](https://metacpan.org/release/KENTNL/App-DH-0.004001/source/example/dh.pl)
off of metacpan.

Here it is in its entirety.

```
#!/usr/bin/env perl
use strict;
use warnings;
use App::DH;

App::DH->new_with_options->run;
```

With this script, if you use `write_ddl` then it will either prepare a
deployment or an upgrade, depending on the current state of your database and
schema.

And that's it! That's all the moving parts. Add a `schema_version` to your
`Schema.pm` and use `App::DH` to create the SQL and run it.

[^2]: [https://wiki.lspace.org/GNU_Terry_Pratchett](https://wiki.lspace.org/GNU_Terry_Pratchett)

# What did that do, then?

OK, so `prepare_deploy` is somewhat the cornerstone of DeploymentHandler. Even
though you're unlikely to deploy a database at the latest version directly, you
still need the deployment YAML. This is the file I described earlier; it is a
serialised version of the structure of your database right now. In order to
create a migration from version X to version X+1 it needs a *complete
description* of the schema at both of those versions. Then it does black magic
and outputs SQL that represents that difference.

You'll notice that you get a `deploy` SQL file at each version. This seems fine
except for two things:

* You don't get the version table when you do this, so you would still have to
  install the version table manually if you deployed at any other version (or
  prepare it each time)
* You don't run any of the upgrade scripts if you deploy a version later than 1,
  which means you'd have to duplicate any special behaviour you put into them.

Generally I don't really recommend doing anything other than deploying version 1
and then upgrading to the current version. You can override the version you're
working with, since by default it's working with `schema_version`.

```
$dh->deploy({ version => 1});
$dh->upgrade;
```

# Extra bits

As I intimated just now, you can add custom behaviour to each upgrade, or even
to the deployment itself. The fact that you get *files* out of this makes
DeploymentHandler somewhat unique in the grand field of database migration
handlers. Most others that I have worked with have simply attempted to use the
code itself - the schema modules, or language equivalent - to deploy or upgrade
a database.

The fact that DH gives you *files*, and SQL files at that, means that you can be
absolutely sure that there's nothing going to break in future, because they are
now immune to any new bugs in future versions of DH, and if there *is* a current
bug in DH, you can edit the SQL file to be correct before you commit it.

It also means you can add data to the database as part of the database upgrade
(or deployment).

You can also add *Perl scripts* to your upgrade process, which means you can use
the DBIx::Class modules themselves to do things with data that just aren't
possible, or get cumbersome, with pure SQL.

## But I already have a schema and a database!

That's fine. App::DH doesn't handle this but you can extend it, or just write a
special patch script. All you have to do is put the version table in your
database and insert the current version into it.

Here's a complete script that does that.

```
#!/usr/bin/env perl
use strict;
use warnings;
use My::Schema;
use DBIx::Class::DeploymentHandler;

my $dh = DBIx::Class::DeploymentHandler->new(
    schema => My::Schema->connect('dbi:SQLite:existing.db'),
);

$dh->prepare_version_storage_install;
$dh->install_version_storage;
$dh->add_database_version({ version => My::Schema->schema_version });
```

Of course you will want to adapt it to connect to an existing database, but
there you are, job done.
