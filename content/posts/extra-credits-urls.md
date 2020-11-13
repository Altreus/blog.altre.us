---
title: "Extra Credits: URLs"
date: 2020-06-05T19:21:49+01:00
draft: true
series:
  - Extra Credits
tags:
  - http
  - url
  - web
  - internet
---

The URL was invented in 1994 as a solution to the problem of identifying
resources on a networked system. It merged some standards already in place,
including the pre-existing path syntax still in use today.

I never showed you what the structure of a URL is in general. Here it is:

    scheme:[//authority]path[?query][#fragment]

The brackets are a common syntax to denote optional parts, which fits with what
we said in the main post.

The authority part of a URL looks like this:

    authority = [userinfo@]host[:port]

Let's talk about that.

{ $TOC }

## Authority and authorisation

### Who are you

The URL specification has a `userinfo` part in the authority section. This is an
old way of supplying user information and it is now deprecated.

The URL came about during a time when the Internet was mainly used for academic
purposes. This meant that authorisation was mostly restricted to a simple
username and password[^1]. We still use username and password authentication today,
but we don't consider it to be secure at all to put it in the URL.

    http://user:pass@example.com

[^1]: The `userinfo` section can be just a username. The `:` separates the
  username from the password, so if there's no password, there's no colon.
  This can be used to have a "temporary username" (a bearer token) in the
  URL—but even this is a terrible idea, given the available alternatives (which
  I won't go into here—look out for the HTTP portion of this series).

This is, of course, very insecure. Even if your connection to a server is
secure, the URL itself is publicly visible—it has to be, because it's going to
be used by various systems to figure out how to get you to the resource you've
requested in the first place! That's why this was deprecated.

The mistake, then, was wanting the credentials to be included in the URL. When
we look at HTTP itself, we will disassemble the URL properly and look at how the
different parts are used. We'll look at authorisation in more detail then.

### Any port in a storm

The authority part of a URL is intended to be used for an external server. This
can be the IP address or hostname for the server. The hostname is just a
human-readable alternative to the IP address and the computer will use DNS to
translate from one to the other. (A future post will cover DNS.)

External servers expose their behaviour to the outside world by attaching a
piece of software to a port. This is just a number that you pick when you run
the service. The operating system deals with how that really works, but note
that the port in question is a virtual one and not a hole in the back of the
machine. This simply allows incoming network traffic to determine which service
it uses, by specifying which port on the server it wants the request to go to.

There is always a port. By default, HTTP traffic uses port 80, and HTTPS traffic
uses port 443. However, it is not necessary for you to run your server software
on these ports, but if you don't, you have to communicate to your users the port
you are using. This is a social problem, so we don't care about it.

The technical problem this poses is that you must then be able to provide the
intended port within the URL. This is done with a colon on the authority part of
the URL.

    https://test.some.domain:8080/posts/draft-post.html

It is common to run test servers on a different port, and you can put this port
in your browser to access the test version of the site.

Ports in a UNIX system are divided into two categories. Below 1024, the ports
are reserved for system services and require root access to configure. 1024 and
above, however, are free to be used by non-privileged users of the system.

This means it is very simple for you to develop against a running server, for
something like a blog, by running that server against a so-called "high port" to
which you have access. This blog uses [hugo](https://gohugo.io), which runs on
port 1313 by default. When I run it, it builds my blog site on the fly, and when
I make changes, it automatically updates the filesystem. Then, when I go to
`localhost:1313`[^2] in my browser, I can see the blog as it will look when I publish
it, except when I make changes, they show up instantly with just a refresh.

[^2]: `localhost` is the builtin friendly name for the computer you're currently
  working on. This tends to cause confusion when you try to share your
  work-in-progress, because to other people, your machine is not localhost.
  Hopefully this series will improve internet literacy to the point where that
  is no longer a point of confusion.

### A distressing lack of authority

I mentioned in the main post that a URL doesn't have to have an authority. The
authority of a URL is ... well OK it's the domain. It's called an authority
because not all URLs are web URLs, but frankly most of the time you'll be
talking about a web URL.

There is [a big list on
Wikipedia](https://en.wikipedia.org/wiki/List_of_URI_schemes) of registered
schemes, as well. You can see that not all of them require an authority; most of
the ones that don't require an authority tend to be things that act locally,
like the `about:` pages. Yes, good old `about:blank` is a URL!

Another common authority-free URl is a `file` URL. [A footnote in the main
post](/posts/my-name-is-url/#fn:4) points out that the weird triple-slash often
found in file URLs is simply because the file itself is an absolute path,
meaning it starts with a slash. On UNIX systems this means it's anchored to the
root path.

Generally speaking it is the scheme of the URL that decides whether or not it
needs an authority part. This makes sense if you have a shufty at these two URLs
side-by-side:

    https://server/path/to/file.html

    file://server/path/to/file.html

In the `https` URL, `server` refers to a server, something that will provide a
file via HTTP, something that is somewhere else (probably) and requires a
network connection to access.

In the `file` URL, `server` refers to the first part of the file path. This
is because file URLs cannot point to an external server.

When I mentioned the weird triple-slash in `file` URLs I explained it as the
start of the path, because the path is absolute. In case you didn't make the
connection, this means that paths don't have to start with a slash, because they
don't have to be absolute. The alternative is *relative*, but this word, as you
may be able to guess, implies they are relative *to* something. It is rare for a
file URL to point to a relative file, so the path always starts with a slash.

But *in general* the URL standard allows for an authority part, or no authority
part, and it turns out to be fairly easy to define that.

## The use and misuse of query strings

The point of a query string is to restrict or otherwise alter a resource from
its default state. It's called a query string because its primary function, and
original intention, is to create resources that expose some sort of data set,
and this data set can be queried. That is, it's there so you can ask for
something specific.

The entire URL is also there so you can ask for something specific.

Obviously there is a difference, therefore, between querying for a specific
thing, and directly accessing that specific thing.

Let's do it by example. It is extremely common to see query strings like this:

    /addresses?address_id=1234

If we have a look at [how to choose a
URL](/posts/my-name-is-url#choosing-a-url), it looks like whoever made this URL
chose to make a resource called **addresses**, and then make it so that in order
to select a particular address, a query is made.

But hang on, what we already know about *resources* means that, to be a
resource, it must be identifiable—and nothing more. This means the reverse is
true: if it can be identified, it is a resource.

We also saw a simple way to make paths in a resource-based system—for example,
the internet.

    /resource-type/resource-identifier.

Surely, here, **addresses** is the resource type? And the resource identifier
part of the path is omitted? Is "an address" not a resource?

Well—yes. The above path really should be

    /addresses/1234

It was erroneous in the first place to set up an address book index and use a
query string to select addresses from it. The address can already be directly
accessed by its identifier, so the URL should be used to access the resource
directly.

The difference is essentially down to that: whether or not the thing you are
querying for has, itself, an identifier. Our example use for a query string in
the main post was a search engine, and this is indeed a good example. The search
for `url` at DuckDuckGo *cannot* be identified uniquely.

Well, maybe that's not the best of examples. Perhaps you could make the argument
that the search string itself is the identifier for those results, and so the
URL should really be

    https://duckduckgo.com/search/url

Perhaps, although I think we're dealing with a grey area here. But DDG is a
simple form with only one field in it, meaning that the line is blurred between
the identifier for the search results and the values for the form field that
generates those results.

Not all searches attempt to be clever with a single field. You may be familiar
with using administration tools, like a CRM, where you could use a form to look
up individual users or a collection of them. In these cases, the fields
available to the resources would be exposed and you can make queries based on
some or all of the information you have.

    https://intranet.example.com/crm/customer-search?email=example.com&age=21-30&country=uk

Here we've constructed a hypothetical customer search that can look for those
with email addresses that match a given string, an age within a given range, and
presumably whose address is in a specific country. Sure, you could again make
the argument that this query string is the identifier for those customers, but I
feel like this argument is in bad faith and trying to avoid the use of query
strings for no reason.

It might put your mind at ease to note that the query string is *not* an
identifier for the search results at all. The *combination of fields* is an
identifier for the search results, but these fields are not ordered and not
required to be represented like this.

Here are a few more ways of representing the same query.

    country=uk&email=example.com&age=gte:21&age=lte:30

    email=example.com;age=21-30;country=uk

    country:uk;email:*example.com;age-min:21;age-max:30

I've invented some syntax here but that's sort of the point, too. Query strings
*don't have a standard* and you can do *whatever you want*. I've reordered the
fields, I've changed the formatting, I've separated the age field; I've done a
bunch of things that could all represent the same result set, but that all
identify it in a different way.

The point that underlies this point is that the result set is identified by an
*interpretation* of the query string, but the identifiers for resources are
*not* subject to interpretation at all.

Let's bang on this drum a bit longer with some more analysis of the query
string.

### Don't use a query if you're not asking a question

Remember how I said that we don't just pick random words to name technical
concepts? "Path" is similar. The path is the route you follow to get to a thing.
A real-world address is a path, really; it directs you from a massive context
like "the entire planet" to a specific door thereupon. Certainly it's not a path
like you'd find through a park, but it's a path through *concept space*, leading
you from reference frame to reference frame until you arrive at the resource in
question.

Using a query string to pull out a resource from another, broader resource is
somewhat like having a block of flats where each individual flat has a number,
but you have to ask the person at reception to deliver the mail to it. Although
you could probably work out, yourself, which door to go to, what you've been
told to do is basically to ask the building to deliver the mail for you, once
you get there.

In some circumstances, this makes sense; when you go to the library, you
ask the librarian to help you find the book you're looking for. That librarian
is akin to a search resource.

But note, also, that by restructuring the path like we did, we remove this bit:
`address_id=`. This piece of information added no value to the URL. We *know*
it's an address ID, because it's in the **addresses** area. Even if it just said
`id`, we know it's an ID! That's the only piece of information we have! By
removing duplicate information we land on the shortest, and thus tidiest,
possible address for that resource.

### Say what you mean

There's another consideration, and that's of computational efficiency. Remember
that I mentioned how some resources are generated by software, while other
resources are files on disk ready to be sent directly to the client? By using a
query string for your path structure, you are *guaranteeing* that you need some
software to interpret it for you. In contrast, if you use a proper path, you
open up the possibility of simply using that path on your server to find a
pre-cached resource.

Certainly it is the case that there is always going to be something running to
handle the request. Every web server needs web server *software* so that there's
something to understand the URL itself. It is a common strategy to have a simple
web server set up to send static files directly to the client. This blog is set
up like that: every HTML page is generated once, and [nginx](https://nginx.com)
is used to handle the request, peek at the URL, and just send you the file that
you ask for. This is also done for the images and other resources that make up
this blog.

At the time of writing, none of this blog is dynamic—that's the opposite of
static. That means that adding a query string to things will have absolutely no
effect whatsoever. However, I am in the process of writing a small application
to show the uses of a query string, so stay tuned.

Anyway—imagine if I had another application running, besides the web server
itself, that had to *figure out* what file to produce when you clicked on a
link, just because I wanted to use a `?` in my URL. It makes no sense. It would
mean that I cannot possibly simplify my web server setup, because I am beholden
to my own design that I will use a `?` for no reason, and thus I must support my
own special application to handle them.

## Percent-encoding

The URL is a way of using common characters
[(ASCII)](https://en.wikipedia.org/wiki/ASCII) to identify a resource. When you
do things like that you inevitably start providing meaning to characters that
previously had none.

The rules for which characters you can use where are a little bit convoluted.
There are reserved characters, except you can use them in different places
sometimes. Suffice it to say that certain characters may be relevant to the URL
itself, and as a result cannot appear in the name of the resource, or the query
string, or the fragment.

If you're not familiar with ASCII I'm not going to go into it right now; the
important part is that it associates numerical values with characters—127 of
them. These numerical values can be encoded in hexadecimal[^4], `00` to `7F`.

[^4]: Not going to go into numerical bases either!

One thing we haven't covered, then, is that you can always use a reserved
character in a URL by encoding it by means of its hexadecimal. The indicator
that you have done this is the percent character `%`. This is why it's called
percent-encoding.

The simplicity of this solution is elegant: if you want to use a percent
character in the URL, you just encode the percent character with
percent-encoding.

You will probably have seen this as `%20`; 20 is the hexadecimal representation
of a space. Some browsers now decode the space, uniquely, and display it in
the address bar. You're also very likely to have seen this strategy when
following Wikipedia articles with ampersands in the name:

    https://en.wikipedia.org/wiki/B%26M

Again, this is because the ampersand is special in URLs; although, in theory,
not here. Characters not special to URLs don't have to be percent-encoded, even
though they may seem mystical to you. This is because you've been trained to
assume computers are rubbish at representing special charcters, like accented
ones, or other scripts like Cyrillic or Greek or Kanji. In fact

## The URI and URN

We glossed over this a bit in the main post. The URN is similar to a URL, and
the URI simply covers both at once.

URN means Universal Resource Name and it complements the URL by, rather than
providing instructions on how to access the resource, it simply provides a way
of naming one.

URNs basically look like this:

    urn:namespace:name

The `namespace` must be registered with the [IANA](https://www.iana.org). This
is because URNs aren't useful if the namespace is not known somewhere. IANA is
the organisation tasked with this sort of thing.

Anyway, that part tells you what sort of thing the `name` part refers to. My
favourite example of this is `isbn`, because ISBN helps you understand the
difference between URN and URL. An ISBN identifies a book, but you can't use it
to *get* that book. You can't click on it and receive the book, but you can
still use it to uniquely identify a book. Not a single book as in a lot of bound
paper, but the contents of the book: the intellectual property on those pages.

So then the `name` part would be the actual ISBN: the number that identifies
that publication.
