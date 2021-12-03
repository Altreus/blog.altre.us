---
title: "My Name Is URL"
date: 2020-09-16
series:
  - Web fundamentals
tags:
  - http
  - url
  - web
  - internet
---

This post is the first in a series on web fundamentals. The series was inspired
by a perpetual amazement at the amateurish output of professionals working at
large internet companies.

In this post we will look at the URL, which we have all seen in our browsers'
address bars, and plastered all over social media. Hopefully, by the end of the
article, you will understand the structure of the URL, and have enough of an
understanding to be rightly appalled at some of the ones you see in the future.

Although it's the first chronologically it is not the first in the sequence. We
will be filling in some base knowledge and expanding upon this knowledge in
future posts. However, the URL is the first point in the timeline that most
humans interface with this whole area of understanding, so here's where we
start.

* [Episode 1: The URL](#episode-1-the-url)
  * [URL Structure](#url-structure)
    * [`https://`](#https)
    * [`blog.altre.us`](#blogaltreus)
    * [`/posts/my-name-is-url`](#postsmy-name-is-url)
  * [Choosing a URL](#choosing-a-url)
  * [Accessing a URL](#accessing-a-url)
* [Other URL pieces](#other-url-pieces)
    * [`?q=url`](#qurl)
    * [`#links`](#links)
* [Epilogue](#epilogue)


# Episode 1: The URL

URL stands for Uniform Resource Locator. If we analyse this term we'll realise
that we probably started our blog series somewhere in the middle, because it has
come to light that we don't know what a *resource* is.

Well, we could spend an entire post defining resource (and possibly we should,
so it can be looked up later), but we don't really have to: a resource is
essentially anything that can be identified. A house, a book, a person, a
position on the globe, even a list of other resources. The ability to identify
the thing is sufficient to call it a resource.

The URL is something that fully identifies that resource. You may think that,
for example, your National Insurance number identifies you; but this is only
true if you know that it is a National Insurance number. That is to say, you
need information about the type of resource (and where it is) in order to fully
identify it. The URL does that.

One important feature of a URL is that you can *follow* it. This means that if
you access it, you will *get that resource* (or a copy of it, at least).[^1]
Basically, you can click on a URL.

[^1]: URL is part of a family; the URL, the URI, and the URN. All of these can
  be pronounced, if you try hard enough[^2]. URI covers URL and URN, and the
  difference between a URL and an URN is that an URN is not necessarily
  accessible, while a URL points to something that can be accessed. An example
  of the URN is an ISBN; it identifies a book, but you cannot click on it to get
  the book.

[^2]: Despite the name of the blog post it got a bit tiresome constantly trying
  to use URL as a word. Reading the separate letters seems to be the norm so
  I'll be assuming you read it the same.

Like many things on the internet, the URL has an RFC, which can be found
[here](https://tools.ietf.org/html/rfc1738). The URI also has an RFC, which can
be found [here](https://tools.ietf.org/html/rfc3986). The opening paragraphs may
give you some insight into the difference, but in general they are a dry read
and I wouldn't bother[^3].

[^3]: This makes it harder for you to correct me.

## URL Structure

![A deconstructed URL](/images/my-name-is-url.svg)

The URL comprises a few named parts which you should be able to recognise. Let's
start with a simple one, the address of this page (as of writing, at least):

    https://blog.altre.us/posts/my-name-is-url

This blog post is a *resource* because it is identified by its *title*. Original
as the title is, however, it is probably not unique across all blog posts in the
world. Similarly, your house probably has a number; this is not unique to all
houses, but it is unique on your road. Your road's name is probably not unique,
but it is unique in your area! And so on.

Hopefully, the reason why URLs are called "web addresses" is clear.

Let's pull the address apart.

### `https://`

This is the *scheme*. Your web address will always use `https` because of two
reasons:

1. The web runs on HTTP, so all web addresses use HTTP schemes
2. It's 2020, and all web addresses are secure, or you get a big slap on the
   wrist and no traffic.

The `://` part is [widely regarded by many to be a bad
idea](http://news.bbc.co.uk/1/hi/technology/8306631.stm). However, it's here to
stay. The colon separates the schema from the rest; the double-slash... exists.

### `blog.altre.us`

This is the *authority*. People tend to think that words used in technology are
magical, but we as a society chose them from a pool of existing words when we
need to name our concepts. In this case, the authority is simply the thing that
is in charge of what the rest of the URL means.

> a person or organization having political or administrative power and control.

In some cases the authority section contains much more, but here the authority
is simply a domain. A domain is an area of ownership:

> an area of territory owned or controlled by a particular ruler or government.

Similarly, a domain on the internet is just the name of a bunch of stuff all
owned and controlled by the same people (by and large).

In my domain, I have the authority on what the rest of the URL means.

A URL does not have to have an authority! More on that in [extra
credits](/posts/extra-credits-urls).

### `/posts/my-name-is-url`

This is the *path*. You can tell it's a path because it looks like one. Windows
users will be confused: aren't paths stuff like `C:\Games\Minesweeper`? Sorry to
report that you're special! Everyone else[^4] uses the forward slash here.

[^4]: I cannot speak to unusual operating systems like OS/2 and TempleOS.

A path on your operating system refers to a file. A file is a resource. On the
internet, the path does not have to point to a file. The resource could be
generated when you request it—this is what search engines do, for example.

UNIX-like operating systems use the same path format as URLs because these paths
refer to resources. Not all paths on a UNIX-like operating systems are actual
files; some of them refer to devices, or system information, or other resources
like a random number generator.

If it were not for the requirement that the URL have a scheme, UNIX paths would
All be URLs[^5].

[^5]: You can turn a file path into a URL by using the `file://` scheme.
  Sometimes you'll see `file:///`—this third slash is because *the path
  itself* begins with a slash. This is exactly what you'd expect from a URL with
  no authority part.

## Choosing a URL

Most of your URL is chosen for you, but you have control over the *path*. Well,
you have control over the domain, but once you've chosen your domain name, it's
pretty much set in stone.

So your job, when making URLs, is to pick sensible paths.

A common path structure is:

    /resource-type/resource-identifer

Honestly there isn't really much more to it. If you want to pass around a link
to your stuff on the internet, this is really the only way to do it. Yes, that's
just my opinion, but it's also the right opinion, so there!

Frippery aside, this structure is simple and common on the internet. Keep it
simple, stupid! On this blog, the resource type is "posts", and the resource
identifier is the name of the post.

OK, there will always be exceptions. For example, the `/about` page is not a
resource type, it's a resource identifier. It doesn't have a resource type
(perhaps "meta"?), but also, it doesn't need one.

Similary, some resources are better described with several levels of resource
types. Maybe it's useful to put `archive` in there somewhere, or to name
different areas of your site. Maybe you have more than one things with posts in!
You could easily have `/forum/posts/...` and `/blog/posts/...`.

## Accessing a URL

Earlier I said you can click on a URL, and this is true. I want to lampshade
this point a bit more, however, because it touches on something that might not
be immediately obvious. The fact you can click on a URL indicates that any
software that recognises a URL knows how to make use of it.

I've been saying "click on" because that's probably the most common way a human
interacts with URLs (that, or tapping on them with a touchscreen device). And
that's almost certainly true for `https` URLs. But there are other ways of
accessing URLs, depending on their type and what your use case is.

If you provide a URL to the `curl` tool it will perform the same tasks as your
browser but output the result on your terminal instead of rendering it as a web
page. Some URL schemes instruct the OS to open certain applications. Steam [has
its own URL
scheme](https://developer.valvesoftware.com/wiki/Steam_browser_protocol) that
gets Steam to intepret the URL. [So does
Zoom](https://marketplace.zoom.us/docs/guides/guides/client-url-schemes).

This idea is backed by a more important one: the URL *standard* contains
sufficient information to allow applications to use the URLs correctly. If you
want to know how to recognise a URL when rendering text, or what to do with a
URL when you receive one, you can refer to the documentation.

# Other URL pieces

We've looked at a simple URL but we should consider a more complex one, because
URLs have more parts than that.

    https://duckduckgo.com/?q=url#links

If you follow this URL (which you can, because it's a URL!) you will be taken
to a DuckDuckGo search for the term `url`, and if it still works your page will be
scrolled down to the top of the search results[^6].

[^6]: At the time of writing there's a bug in DuckDuckGo whereby it rewrites the
  URL on load, for some reason, and gets the rewriting wrong. However, the
  behaviour appears to remain correct. Be aware that the URL in your browser
  will not match the one I'm talking about as a result of this bug.

The URL now encodes two new pieces of behaviour, and contains two new parts, so
let's focus on those.

We know about the scheme and the domain, so let's start with the path. Unlike
Google, DDG doesn't actually bother to name its primary resource. On Google, the
search results are at the path `/search`, but at DDG the search results are at
the path `/`. This is called the *root path*.

The new parts are identified by a `?` and a `#`

### `?q=url`

This is called the *query string*. I chose a search engine as an
example on purpose because it exemplifies the purpose of a query string. In
truth, any resource on the internet can use a query string, although the vast
majority of them don't. This is because most resources on the internet are just
static things like images and pages.

The query string allows you to provide parameters to the resource. I mentioned
that every resource on the internet can accept a query string; this is true, but
unless the resource is created to make use of it, it will simply do nothing at
all. Try it yourself with any site you currently have open: if there's no ? in
the URL, add one, and some gubbins after it, and see if it reacts.

In the case that the resource *is* designed to accept parameters, this is how
the parameters are provided. There is absolutely no restrictions on what the
query string can contain[^7], but the particular resource identified by the URL
will almost certainly only understand certain queries.

Trying to think of a good example—oh! A search! In our DDG example, the root
resource is returning the results of performing a search on a massive database
of information somewhere. The *capability of searching* is the resource; it
qualifies as a resource, though, because it can be identified.

In our example, the query string is being used to send parameters to the
resource by using a simple key=value sort of structure. If you were to change
the `url` part to something else, you would find that you are searching for
something else.

    ?q=something+else

The `q` key is meaningful to DuckDuckGo; they understand it to refer to the
query. Slightly confusing - the query string has a query key in it! Actually,
that's very likely why it has that name in the first place; the query string is
the place where you can send a *query* to the resource.

It is extremely common to see a query string structured like the one above. For
multiple parameters, we simply use `&`:

    ?q=url&source=my+blog&tracking=off

This is a *convention*, not a *requirement*[^8]. The query string can be *anything
at all*[^7]; it is up to the software that handles your request to interpret it.
However, the above convention is so common I have not been able to find an
example that contradicts it.

I mentioned "the software that handles your request". It is probably not
immediately to obvious to anyone not familiar with the subject that when you
receive data in your web browser—the response from requesting a resource—there
is absolutely nothing in the whole magical internet system that says *how* to
produce that data. DuckDuckGo do not have a massive directory on disks in
datacentres that store every possible result of every possible query! But I bet
they have image files on disk that contain their logo. The *searches* are
generated on the fly, while the *static* resources (like the logo) are just
stored as files in datacentres.

There will be more on the concept of resources in a future episode.

[^7]: Literally anything. There is no standard limit to the length of the query
  string, but one is often enforced to prevent attacks. This said, we discuss
  the restricted characters for URLs in [extra credits](/posts/extra-credits-urls).

[^8]: This format is the `application/x-www-form-urlencoded` [MIME
  type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types)

### `#links`

This is called a *fragment* and can also be anything at all. The difference
between a query string and a fragment is that the fragment is not sent to the
server. It is *entirely* for the use of the client.

The client is your browser.

So, the client makes use of it. When a browser sees a fragment, the first thing
it will try to do is find an element on the page that has the same ID[^9]; if it is
found, it will scroll the page to that element. Basically, this lets you put a
link to a *section* of a page, rather than just to the page itself.

[^9]: We'll talk about page elements and their IDs when we get to the post on
  HTML. If I've already written that, hopefully I've updated this footnote with
  it.

Fragments are now used by many JavaScript frameworks to control the way they
work; this is perfectly acceptable, since there is no strict purpose for the
fragment. However, its preferred use is to identify an element within the page,
since the original purpose of all of this was to share structured documents.

(I call it the preferred use simply because browsers will keep trying to do
this, and much of the internet still makes heavy use of this behaviour. It is
how the table of contents and footnotes work in these posts!)

# Epilogue

This is only a brief overview of the URL, even though it ended up not being very
brief at all. Further reading will be available in [extra
credits](/posts/extra-credits-urls) when I've written it. I recommend looking in
there if you intend to make any software that makes use of URLs, even if it's
just a blog where you have control over the paths. We will discuss the concept
of a resource in more depth, and look at more uses of the various parts of the
URL structure. We might even use the word *protocol*, which is a very cool techy
word indeed.

In the next episode we will look at HTTP.
