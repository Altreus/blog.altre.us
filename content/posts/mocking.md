---
title: "Making a Mockery"
date: 2022-09-23
series:
  - Software development
tags:
  - development
  - testing
  - unit testing
  - mocking
---

This blog post is about mocking.

Mocking is a practice by which you replace parts of the system with fake
versions for testing. This is easier to do in some languages than others, and
the easier it is to do, the more likely you are to do it.

With great power comes great responsibility, and it is possible to wield the
power of mockery to do great things. Terrible, but great. Use it wisely, but
don't overuse it.

## Don't change what's not yours

See, there is a great temptation to mock out anything that might get in the
way. Mocking generally goes well with dependency injection: you can create a
fake object that pretends to provide a service, but doesn't, so that when your
unit test is running, what would once have been a possible quagmire of complex
function calls, and possibly network calls to external services, instead you
are running a single function that *you control*, and therefore you can
meticulously and accurately decide what should be returned from that service.

The problem here? That is not your service. You are not the arbiter of the
input and outputs of that service.

## Who controls your IO?

This is where a language with "strong typing" comes in useful. Strong typing,
here, refers to the idea that the compiler, or at least the runtime, of the
language can keep track of what a given piece of data *is*: it is of some type,
defined either by the language or the developer. The purpose of this is to
constrain the behaviour of functions by declaring the types they use for
communication. Functions accept parameters and return values; and if the
compiler knows what types those parameters and values have, then it can tell
you if you use them wrongly. Crucially, it can also tell you if, by changing
them, you break something else that was relying on that thing you changed.

This would mean that creating a fake service and injecting it as part of a unit
test of another thing would be far less dangerous if you were forced to ensure
that the mock object returns compatible data, or else your program simply will
not compile.

By specifying data types for that communication you do not *need* to be the
arbiter of that service, because the person who *is* the arbiter of that
service has specified exactly how it works: all you have to do is conform.

Great; but we're not using strongly-typed languages. We're using Python and
Perl and Node, where we communicate with dictionaries and hashes and objects:
untyped, loosely structured data whose constraints are documented, not
computed.

So, I say again: you do not own that service.

## You keep saying "service"

I'm using the concept of a service as a sort of stand-in for any behaviour that
you are not testing, but you are relying on. I'm also intentionally not talking
about what type of test this is, except that it's an automated test, which
means that the computer runs a script, and it's up to the developer to write it
in such a way that if something is wrong it shows up as a failure.

The point is that, when you're running such a script, you're going to be
focusing on something in particular. Even if it's an integration test, where
the whole point is to check multiple things working together, you're still
going to have decided on a scope for the test. You're still going to decide
that this behaviour is worth testing here, and that behaviour is not.

So a service, then, is any behaviour that the stuff you are testing relies
upon; it may be in scope, and it may be out of scope, and if it is out of scope
then this is a candidate for mocking. It need not be an actual *service*, in
whatever service-oriented architecture you're using; it could be a single
method of a single class, or a function not even part of a class, or something
like that. The point is that you've identified it as behaviour that is being
run, but that shouldn't be run.

## That is not yours to change

Let's say you've identified a service that shouldn't be run. Perhaps it calls
out to an external host, and your tests are supposed to run in an isolated
environment, and so can't rely on network connectivity. Or maybe you just don't
want to wait for an expensive operation to finish, just to test something
that's ultimately unrelated to it.

You may be tempted to mock it out.

Don't.

As soon as you create a mock for that service you have tied yourself to the
service as it works at that point in time. I can guarantee that whoever is in
charge of maintaining the real service has no idea that you've mocked it out in
that test: even if that person is also you. You're going to compartmentalise.
Remember, the whole reason you're mocking it out here is that it is not in
scope for this test. It's irrelevant. It's an incidental part of the system
that you want out of the way. Are you really going to store that in some giant
index in your head of all the places where everything is used? No, of course
not. You're going to make the test work and then immediately forget about it.

And then, later, you're going to change the real service. And you're going to
change the code that you *are* testing. But you're not going to change the
mocks, because... ah.

Because you've taken charge of too much stuff.

## A totally fake and not at all real case in point

Let's be concrete about this, and pretend to invent a case study.

Altreus, your case studies are always so realistic but you always assure us
that they are made up to illustrate a point.

Kind of you to say so. Moving on.

We're going to create a web page with a form on it that performs a search when
submitted. OK, done that. Now we are going to write a unit test.

We wrote the controller in terms of a service called `Search`. At the time,
this just searched the database, using awkward SQL queries and trying to use
indexes properly. It returned the search results, plus some information about
how it interpreted the parameters it was passed in the first place, and maybe
some metadata like how many results there were.

So we mocked out that service when we wrote the test. That is not required in
order to test how the controller is doing. In fact, it's better if we replace
it, because that way we can control exactly what `Search` returns each time we
call it. This is fine, because we also know what data we are going to send
it.[^1]

[^1]: Alternatively, you can set it up so that you tell it what data we
  *expect* to send it, and fail the test if something different shows up.

Later we discover that there are way better ways of searching, like Solr and
ElasticSearch and things like that. So the `Search` service updates. Now it
tells you where it searched, how it searched *that* database, etc.

The test, however, continues to work. That's because you mocked something that
wasn't yours. You set the test up to pass, so it will pass when it shouldn't.

In a sense, that's fine. It's a unit test. You're testing that *that unit* has
not broken as a result of *that unit* being changed; which it hasn't.
*Integration* tests are there to check that the unit hasn't broken as a result
of a *dependency* changing.

Did you write an integration test?

That's OK, UAT will catch it. I'm using that term to mean when someone actually
launches the website and sends data to the search page. This will go wrong,
because the controller has not been updated to handle the new interface.

That's just extra work, though, and nobody likes it when code comes back with a
whole chunk of extra work to do. Now you have to fix the controller to use the
new interface *and* fix the test to *mock out* the new interface.

Consider, also, that the person who now has to fix the controller is not the
person who wrote it (you) but the person who changed the Search service
(someone else). So now *they* have changed code *you* wrote and when you come
back to it you'll be doing the John Travolta meme because you won't recognise
any of it any more. And suddenly you realise you don't understand the new
interface so you can't maintain your own code any more!

Well, maybe that's a bit excessive. We're all professionals, after all. But
consider how much easier this would have been if, instead of mocking out the
`Search` service, you mocked out something one level down! What if you mocked
out the ElasticSearch service, or the database? That's the sort of thing you
can mock out far more easily - SQLite, for example, can be a real database
in-memory, in-process! You can put real data into it and let the `Search`
service discover it.

That's what I mean by it's not yours to mock. If it changes, things that use it
should immediately start failing (presuming the change is not
backwardly-compatible). But if you mock at the wrong level, all you do is
create an echo chamber: a test that only really tests itself, and is set up to
pass.

## And then

And then someone decides we want to log what sorts of things people search for
so we can get analytics on it. So a `Log` service shows up and gets added to
your controller. It's called that because it's not the only thing they'll want
analytics on, so it's a generic service that can log any old behaviour, one of
which is searches.

So, dutifully, you also mock the `Log` service in your test, because if you
don't, the test fails, because the service is trying to connect to something
that doesn't exist. As long as the service *is* called, we can be happy that it
is doing its job.

What you've overlooked, however, is that this controller is the only place that
the `Log` service is being used to log search results.

Sure, there's a unit test for it! It tests, and proves, that if it is sent the
right data it does the right thing, and if it is sent the wrong data it
correctly throws errors.

What you have not tested, however, is that your controller *is* sending it
correct data. The unit test proves that it *would* behave correctly *if*
certain conditions were true; but when you *use* a service, you must also test
that your service does not provide those circumstances in which the service
errors!

Because the unit test mocks out both the `Search` service and the `Log`
service, it short-circuits the only part of the system that actually sends data
from one to the other. You've neutered the validation of the `Log` service,
because you've taken control of it: and you've silenced the `Search` service,
and you're speaking on its behalf.

The only way that you can test that your controller correctly makes use of the
return value of `Search` and gives it to `Log` is to actually let both of those
services do their job.

## One level deeper

OK, fine. You were mocking out `Search` and `Log` but now you're mocking out
`DB` and `ElasticSearch` and `Kibana` or wherever those logs were going. That
means that your immediate dependencies get to do their jobs. It's a bit more
awkward, granted, because now you have to mock out a more complicated
interface, or actually run those services somehow and get data into them, but
at least if something changes that will break in UAT you don't have to wait for
UAT to catch it.[^2]

[^2]: OK, let's say you *did* write an integration test. That one runs without
  mocks, but instead in an environment with a real external thing actually
  handling search queries and log requests. This fails, rather than waiting for
  human testing to discover it. But you *still* have to go back and fix the
  controller and then the unit test that had all the mocks in it. All you did
  is find it quicker.

What about other services? Are you mocking everything? Are you testing what
services are in use? Should you be? (Hint: no).

You've really just kicked the can down the road. What happens if something
changes what services it's using? Have you accounted for that? If something
requests a service that you're *not* mocking, do you just give it the core,
unmocked service? Or do you throw an exception and refuse to run the test?

Both of those are perfectly fine, depending on what you're doing, but the wrong
answer is to ignore the request. Depending on your language that will cause
some very strange errors in arcane places.

## What then?

The "unit test" philosophy I espoused above is, in my opinion, a bad one.
Testing is science. Science is about proving yourself wrong. Progress is made
by finding when your theories and hypotheses *don't* work, and proving they
don't work, and updating them to account for that.

In science, you have the null hypothesis. The null hypothesis is basically
saying "The thing I've come up with has no effect". Then you have to come up
with an experiment that can only be the case if what you're saying *does* have
an effect.

That's a test. It's exactly the same. You have to assume that your code is
awful and riddled with errors and we're better off without it. Then you write a
test that proves that you haven't, in fact, just mashed the keyboard and
copy-pasted from Stack Overflow. A test that proves that you really did mean to
put all those characters in that file in that order.

You should be *trying* to make your tests fail. Mocking out things at the wrong
level, or too many things, sets up an echo chamber in which your test cannot
fail, because it is testing itself. That's called begging the question.

If you have code that requires multiple external services to run, perhaps you
shouldn't have a unit test at all. Perhaps your test should be an integration
test because perhaps your code is integration code.
