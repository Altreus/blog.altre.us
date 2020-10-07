---
title: Clearing the rebase FUD
date: 2020-10-07
series:
  - Tools of the trade
tags:
  - git
---

There's a lot of FUD[^1] regarding rebasing in git. People have *very* strong
opinions against using it because they fear that it will completely ruin their
codebase.

[^1]: Fear, uncertainty, doubt

And in fairness to them, this used to be the case. Rebasing code in git used to
be a great way to stomp all over your history and lose changes.

  * [What is rebasing?](#what-is-rebasing)
  * [So why the FUD?](#so-why-the-fud)
  * [OK so what *is* the FUD?](#ok-so-what-is-the-fud)
    * [You can't rebase a branch you've pushed](#you-can-t-rebase-a-branch-you-ve-pushed)
    * [Rebasing is editing history](#rebasing-is-editing-history)
    * [But what about merging?](#but-what-about-merging)
  * [Configuring git](#configuring-git)
    * [Pushing rebased commits](#pushing-rebased-commits)
  * [Unbefuddled](#unbefuddled)


## What is rebasing?

When you commit code to git, the new commit establishes the previous commit as a
*parent* commit. By following these relationships the full history of the
project can be recreated[^2] [^3].

[^2]: In fact the history is *defined by* the commits you can find from any
  other given commit. This is why it's important to make branches: by labelling
  a commit, git knows it's relevant and keeps it and all its parents around.

[^3]: *Garbage collection* happens periodically but not very often. If a commit
  is no longer accessible from a labelled commit, it can be recovered as long as
  garbage collection has not removed it.

The commit can be said to be *based on* its parent.

![A commit, and a second commit](/images/rebase-1.svg)

Next: when you commit code you do it on a branch. A branch is nothing more than
a label that tracks you as you make commits.

![A branch moves with the commits](/images/rebase-2.svg)

It's called a branch because if you *change label*, e.g. by making a new one,
the old one stays where it is. This means you can go back to the other one,
stuck in the past, and make another new one, if you need to. By doing this, you
branch your history.

![A branch stays behind if you make a new one](/images/rebase-3.svg)

The default branch is `master` and this is the name that will track you as you
commit to a new project. Normally you want to start creating branches very
soon—this allows you to see what features are currently active, and allows you
to rewind back to master to start a new feature (e.g. a bugfix) before you've
finished the current one.

![You can make another branch from a point in history](/images/rebase-4.svg)

Just as the one commit is based on its parent, you can say the same about a
sequence of commits. We say that the branch you're on is *based on* the last
branch you get to, going back through history. In the diagram above, `feature`
is based on `master`. So is `bugfix`. This is because the labels you leave
around the place mark the important commits in your history. You can of course
refer to any commit and say everything after it is based on it, but those other
commits aren't really very interesting. (To keep you on track, "after it" is
"above it" in these diagrams.)

If you make a bugfix branch off of master[^4], it's because while working on a
feature branch you've come across an urgent issue that needs fixing immediately.
When you've done that, you have master, without the fix, and a bugfix branch
*based on* master. The master branch now needs to contain the fix, because the
point of master is to represent the latest *working*[^5] version of your code.

[^4]: Choosing the branch to base a new branch on is a topic for another day.
  Bugfix is branched off master because it's easier to draw.
[^5]: Hopefully.

So, you *move* master upwards to incorporate the bug fix. However, now your
feature branch is no longer based on master and does not contain the fix. 

![When you move the base branch, the commit is still
there](/images/rebase-5.svg)

This is because of a fact we glossed over: even though you created the branch
from another branch (i.e. master), that's as far as the relationship goes. As
soon as the `feature` branch was created, the relevance of `master` was lost
completely and is now only known to humans trying to organise their code.

That means that the new commits are based on the *commit* at master, not master
itself.

Well what would you do in this situation? Surely it's obvious: you move it.  And
that's rebasing. You move your branch so it has a new base. Re-base, see?

![If you need to move a branch, move it](/images/rebase-6.svg)

## So why the FUD?

The above section was a small thought experiment in how you might go about
building the change history of a software project. With no contraints, what is
the most obvious and apparent way of achieving this?

We solved the main problem: multiple branches of history where unfinished work
is put to one side, or where multiple people can work on different changes in
parallel. We built a *tree* of commits that represent the history of changes
made to your project by associating a change with its parent, and allowing
multiple changes to have the same parent. When the history branches, you simply
move bits of it around to be in the right place so that they incorporate other
bits of history.

The FUD is there for the same reason there's FUD about Perl: it *used to be*
problematic. It *used* to be bad. It *used* to cause issues whose memories have
stuck around in cultural memory and now everybody avoids it with a pole because
once upon a time if you pressed the wrong button it would zap you.

## OK so what *is* the FUD?

This is going to be jarring because I spent a whole section carefully tiptoeing
through the absolute basics of the git commit tree and now I'm going to talk to
you like you know what you're doing. I'm going to try to fill in some of the
gaps as we go because the solutions to some of the problems do indeed require
you to you know what you're doing. I apologise if there remain bits that are
unclear to you, but brevity is the source of you reading the rest.

### You can't rebase a branch you've pushed

Nonsense.

*Pushing* a branch in git involves sharing it with others. Well, sort of. You
see, git is a distributed system. That means there are other copies of your
history, if you want there to be. Normally you don't start from scratch but
start from an existing codebase. Each such copy is called a *repository*.
There exists only one local repository, and then zero or more remote
repositories.

When you push a branch, what you do is you tell a remote repository that you
have made a branch. You tell it the name of the branch, and which commit it
points to, and then all the commit parent information until you get to one it
already knows about. And behold, now you have an external backup of your
branch.

The purpose of this is manifold, and entirely depends on what you're doing.
However, regardess of why you did it, one thing is true: *nobody else gets your
branch* without performing some specific action.

One more thing is true: that's *your branch*.

Combined, these things mean: "Why do you have my branch?"

In every other copy of the same remote repository, other people will silently
receive enough information to create a local branch in the same place and with
the same name as your branch if they want to. Otherwise, that information is
entirely there so that all copies of the repository are working from the same
information.

Unless they have a very good reason to do that thing, they should probably not do
that thing. They will not have your branch, they will have a local copy of your
branch which has only a loose connection to your branch.

So if you now rebase your branch, their copy of your branch stays where it is
and everything gets confused.

~~You can't rebase a branch you've pushed~~ Stop making copies of branches that
aren't yours if you don't know how to deal with the real owner rebasing them.

### Rebasing is editing history

Git is a history editor. Woe betide anyone complaining that a book was edited,
or a film. While you are in control of a branch you should be changing it to as
great an extent as you need to in order to produce a history that is clean and
sensible.

I think this complaint is really the previous complaint in disguise: the idea
that pushing an edit to history is dangerous because anyone else looking at
that history is going to get issues. "History" is used to refer to the stuff
that's been shared, which is now considered immutable because previously it was
a huge issue to change stuff that had been shared.

Again, the solution is not to use branches that are not yours, and other people
editing their own history will not affect you.

Once a book or a film is published, editing stops, unless you're George Lucas.
You can issue the same ultimatum on your code: stop editing the history after
the product has been published. This seems fair—although you *could* continue
editing that history, there are now other stakeholders in the consistency and
stability of the codebase, and you are better off forging your code out of
free-radical commits in a molten codebase rather than letting it go cold before
it's finished.

### But what about merging?

You mean where you create a commit with two parents to achieve the same thing as
rebasing?

This was not part of our model. I can't see a reason to add it.

## Configuring git

Despite all of this philosophising, git does not set itself up for success. It
has all the tools available to never use merging again, but sets itself up to
assume that merging is what you want, even when it's clearly going to screw
things up.

Luckily there is not much you need to change to fix it:

    [pull]
        rebase = preserve

Git's defaults are focused around merging and I think that's because rebasing
used to be the sort of thing you happened to be able to do, but that was
discouraged in general. This probably stemmed from how VCS worked before git
came along, plus nobody really realising how valuable it could be to edit the
history tree in this way. As people realised it could be done, it gained a more
prominent position in git, and now many features exist to facilitate it.

That is all conjecture, but it is *my* conjecture.

### Pushing rebased commits

Git won't let you push changes if the changes you've made don't apply cleanly
on top of what was last pushed. This prevents you from accidentally clobbering
someone else's work—but see above regarding *don't work on someone else's
branch*. Nevertheless, someone else can easily work on your branch and this
prevents mistakes.

When you rebase you completely rewrite the history of your branch, back down to
where it was originally based, and you copy it atop the new base. This means
that there is absolutely no clean path between the old branch and your new one.

Git now provides a way of splitting the difference here. There is a new feature
called `force with lease` for pushing branches. This forces the branch to
update (i.e. ignore the must-be-clean rule) but only if the branch hasn't moved
since you last pushed (i.e. enforces the nobody-has-changed-it rule).

	git push --force-with-lease

The inclusion of this feature speaks to the promotion of rebasing as a
first-class, expected way of working. The only reason you would ever want to do
this is if you had rewritten the history of a shared branch.

I like to make use of aliases in git:

	[alias]
		pushfl = push --force-with-lease

## Unbefuddled

The FUD has cleared. There is nothing wrong with rebasing. Any problems caused
by rebasing are your own fault, and I can guarantee that 99% of the reasons
your rebasing goes wrong is that people are trying to use other people's branches.

We'll be doing a deep dive into the mechanics of git, remote branches, dealing
with other people's branches, and other stuff we've glossed over in a future
Extra Credits post, yet to be writ.
