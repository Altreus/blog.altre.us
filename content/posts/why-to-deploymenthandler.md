---
title: "DBIx::Class::DeploymentHandler: why"
date: 2022-09-30
draft: true
series:
  - Perl
tags:
  - perl
  - databases
  - deployment
---

I already posted about [how to
DeploymentHandler](/posts/2022-07-28-how-to-deploymenthandler/), and I
specifically said I would not explain why in that post.

This is the why post.

# TL;DR

Much like recipes, I find it very tiresome when a blog post spends all its time
justifying its existence instead of answering the topic.

Here, then, is why I would advocate for DBIx::Class::DeploymentHandler.

* You only make your changes once
* You write those changes in Perl, not in SQL
* Your code and database are guaranteed to agree[^1]
* You make changes in code *first*, and actually deploy the database when
  you're happy with it
    * Of course, you can un-deploy and re-deploy in development as much as you
      like until you have something you like
* You have complete freedom over your result classes
    * As opposed to changing the schema and then importing it into code, where
      you can't update any of the auto-generated stuff
* You have complete freedom over the migrations
    * You can edit the SQL that DH creates and it won't notice
    * You can add extra SQL files and even Perl scripts to be run as part of
      the same migration
* Deployment is handled by the same config file that connects your schema in
  the first place
    * Or not, if you want to restrict the app's user so it doesn't have
      permission to do schema changes
* You can trivially automate the upgrading of your schema as part of your
  application's startup
* You have a sequential schema version system[^2]

[^1]: DeploymentHandler gives you plenty of rope with which to shoot yourself
  in the foot, so this is only guaranteed as long as you don't do that.

[^2]: This may or may not be to your preference. Personally, I prefer it,
  because it means there is a direct mapping between an integer and a schema.
  That makes it *very* easy to say "Do we have X feature deployed?", because if
  the version is greater than or equal to the version in which X was created,
  the answer is yes. It removes all heuristics from the system, and it means
  changes to multiple tables can be grouped under a single version.

Note, of course, that it only actually works if you are using DBIx::Class in
the first place: but this thought leads onto the observation that any ORM in
any language could be coerced into outputting the YAML format that DH uses. The
part of the process where SQL is created and applied is separate from the part
where the DBIC schema is analysed and turned into data definitions, so it
doesn't actually matter where your YAML files come from.

# The Justification

## Migrations

DeploymentHandler is about migrations. If you're reading this as a beginner,
you'll probably have no real idea what that means. If you have any experience
with migrations, you're probably going "Oh, great, those things", because
nobody really has a good experience with migrations.

A migration, in this context, is a script that alters the schema or contents of
a database in line with changes to the code that relies on it. This usually
requires a certain amount of fiddling about, largely because the database in
question is not actually part of the code, but is a separate system, perhaps on
a separate server, and, in bigger systems, is somebody else's responsibility.

There are difficulties with migrations, many of which needn't exist, because
migrations are often done manually. This seems silly, considering we're all
programmers using computers that are very good at doing things automatically.

Migrations are usually part of a process:

* Design new feature, requiring change to database
* Change database to fit design
* Change code to use database design
* Change database again because design was imperfect
* Change code again
* Loop until imperfection is at an acceptable minimum
* Put database changes somewhere for DB admins to run
* Poise code to use changed database
* Run migrations on production
* Deploy code quick
* Hope

The first loop can be done without much concern: you should be able to revert
your database during dev, which means you can have as many goes as you like to
create an SQL file that adjusts the database as necessary. As long as you have
got SQL that applies to *the current database schema*, then the admins can run
your migration as part of deployment.

That's sometimes a challenge, right there. In theory, the schema you designed
against should match perfectly the schema on production; but what have you got
in place to guarantee that? Has someone come along and added an index or
tweaked a datatype so that performance is improved, and now you've made a
migration that can't be applied?

This never happens, until it does. You can ask yourself "who would even do
that" until you're blue in the face but it won't change the challenge in front
of you.

Assuming they apply cleanly, who's going to do it? Surely automation should be
involved here, but it is still often a manual process to deploy these changes.
Any manual process opens us up to human error; we can mitigate this by having
only one file per migration, so really it's all automated except someone
pressing go. But someone has to press go, and here, again, is somewhere that
such processes often fall down, because people are busy and work gets
forgotten.

You also then, as mentioned, have to have the code ready to go, because as soon
as the database has finished being changed, suddenly all the production code is
looking at a database they don't understand.

This can be avoided to some extent by sensible coding. It is not usually a
problem to create a migration that doesn't affect the existing code once run,
though, because the existing code will only break if something it is expecting
goes away; if something shows up, it's just going to ignore it. It's harder to
remove things from the database, but in that case you would do things in the
opposite order: first you would decommission the feature, and then you would
clean up after it.

Yet another challenge, on top of all of this, is that when you are deploying
your code, this is not necessarily the only change you are deploying. With more
and more systems on continuous integration, this is less of a problem, but
before you have that you have a process of setting up a deployment and actually
getting it out, and this can contain several changes, some of which have
database changes, and one of which might have a bug and the whole thing will
need to be rolled back. In that situation, you have to be *really* careful
about what you do to your database, because when the database gets big, these
changes can take a long time to run.

So really, everything is fine *until* you want to automate your migrations. I
would conjecture that most organisations keep database changes as a manual
process precisely *because* it means a human is involved in case it goes wrong,
and nobody trusts automation doing this sort of thing.

## Data models

This is really a separate post, but let me briefly touch on the concept of a
data model.

In any sufficiently large system (i.e., any system that uses data) you are
going to be dealing with one or more *things*. Things that have names, like
Customer and User and Pet and Cluebat. You are going to be doing CRUD on them:
Create, Read, Update, Delete. These are the four horsemen of data and they show
up *everywhere*. In HTTP they are called POST, GET, PATCH, and DELETE, plus
some nuance.

This means that what you *really* want in your system is something that
represents all the things. Some central way of saying things like, "A customer
has these fields and is stored in such-and-such a table. It is related to this
other thing, and when one is created it is automatically given a timestamp and
a generated password."

This is called a data model. Model is a word that doesn't just mean small,
non-functional version made of balsa wood. It means a representation of
something else, in this case an abstract concept of moving parts. By creating a
data model you create an authority on what data your system uses, and how those
data behave.

DBIx::Class (DBIC) provides such a thing for Perl[^3]. It's an ORM, which
basically means that you define data structures that describe the database.
Like what I just said you want.

DBIC provides Result classes, which say what types you have in your data model
and what properties they have, plus how they relate to other Result classes.
This almost directly translates to most relational databases. For each type, a
table; for each property, a column; for each relationship, a foreign key. In
fact, DBIC meshes extremely closely with relational databases because it
assumes that you are using one.

[^3]: There is definitely a debate to be had on whether your DBIx::Class schema
  should *be* your data model, or should *support* it. Let's assume they're the
  same thing here, or we'll be here all day.

## Migrations in broad strokes

Let's break down the migration problem into a few basic parts, without
prejudice to a particular way of working:

There's the code, which expects the database to look like *this*.

There's the database, which looks like *this*.

There's the new feature, which needs the database to look like *that*.

There's a way to make the database go from *this* to *that*.

And there's a human being, writing code.

We need a way to make sure that any database changes required are kept
alongside the code that requires them, and that they don't need interpretation
by a human being when being applied.

The problem is, what DeploymentHandler does is impossible and so we can't do it
that way.

Solutions to this problem come in the form of things like
[sqitch](https://sqitch.org), which are sort of like a version control system
for the database. Sqitch allows you to create a new migration with a comment,
and prepares files for you to populate. The nice thing about sqitch is that it
is completely agnostic about what the migration *does*. This means that it
could affect multiple tables in one go, and atomicity like this is very
important when dealing with difficult problems, because it removes a lot of
complexity.

But this produces its own problems. How do you ensure that your data model
matches your new database? That human error factor is hanging around at the
back, waiting to heckle us just as we deliver our best-timed punchline.

## Asking the wrong questions

So it's at this point that we invent the concept of a schema loader. This looks
at the database and generates a data model out of it, and now you have that.

As you can imagine, this comes with its own problems. In the case of DBIC, you
have a whole file with a section you're not allowed to edit. What's in that
section? Oh, only things you might want to edit, like documentation and data
types.

See, one benefit of writing a data model is that you have data types that
databases might not have heard of. It's not much of a fiddle to convert these
to and from data types that SQL *does* have, and it makes dealing with your
data objects much more natural.

A great example is the password. Databases don't have a password type, but your
data model does, or could, or should. It's write-only, and when you create it
from some string data, it is automatically encrypted before it reaches the
database.

If you've autogenerated your data model, you have to *patch* that to add
behaviour, but if you *start* with the data model, you have a cascading effect
where everything works as expected (or is a fun debugging challenge!!) because
everything is in the right order.

## Everything In Its Right Place

I'm pretty sure I reference Radiohead quite a lot in these blog posts, and it's
probably always this song. That's because the correct solution *looks* correct.
The solution is in the same order as the problem.

In this case, I offer you this perspective:

> The database can be inferred from the data model because the database
> *supports* the data model.

The database is in a supporting role, so it should be controlled, not in
control. The data model is the most specific part of the system. It has all the
information about data types and how they work and how they relate to one
another. Therefore, the cleanest solution is one that looks at what the data
model wants and supports it; and the data model can facilitate this by
simplifying itself for systems that can't cope.

That password column? To the SQL generator, it's just a text field.

Relationships between data types are just foreign key relationships between
tables.

In theory, you could even have multiple data types stored in the same table. I
don't know of anything in DBIC land that supports this, but again, it would
only be a case of reporting to the analyser that there is only one table and it
requires a set of columns that covers all of the fields in aggregate. You could
(also in theory) then configure it such that, when something is loaded from the
database, it is converted into the appropriate type.

Turns out DeploymentHandler is not impossible, but it took someone who didn't
know it was supposed to be impossible to make it happen[^4].

[^4]: I have no reason to believe anyone thought it impossible, but it makes a
  good narrative. More likely nobody thought of it, or maybe it looked Too Hard
  but not actually impossible. Or maybe everyone was happy with the other
  solution.

## A story for bedtime

Let me lead you out with some real-life insight into how complicated this can
get.

I mentioned that, before CI, you have manual deployments, and to avoid wasting
everyone's time, you tend to deploy when a few things are ready to go at once.

I also mentioned that some database changes can take a long time, and you don't
want to be reverting them.

And I said, to avoid that, you make sure your database can be changed without
changing the code. This actually works! So you can design a deployment process
that incorporates it. Something like:

1. Feature loop
    * Design feature
    * Change code, create SQL
    * Change dev SQL files so the table now looks like that at creation
    * Leave branch lying around in git
    * Label pull request as needing release
    * Add feature to deployment page on wiki
    * Somehow get someone to run the SQL
2. Deployment
    * Create deployment branch at master
    * Merge features listed in wiki
    * Merge conflicts are [a fault with the
      process](/posts/2020-10-07-clearing-the-rebase-fud/)
    * Tag the release and use automation to get it all installed
3. What
    * Load the database back into the data model
    * Regularly remind people to recreate the database because the SQL files
      might have changed

I have added some opinions to this, but the fact remains that it does not have
to be this complicated. If you had a version number for your database and the
database knew which version it was currently on, it doesn't actually matter
*how* the migrations get run, but what it *does* force you to do is ensure that
everybody who wants to change the database have to form an orderly queue.

This, of course, can be achieved by using `git rebase` properly.
