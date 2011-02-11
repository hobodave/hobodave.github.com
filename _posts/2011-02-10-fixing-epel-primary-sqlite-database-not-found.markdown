---
layout: post
title: EPEL: primary.sqlite.bz2 404 Not Found errors
tags: [centos, epel]
---

I recently had an epic battle with yum and the [EPEL][1] repository. I wasted enough
time on it that I think it will be useful if others experience similar problems.

### The Problem ###

I recently installed a new VM with [CentOS 5.5 x86_64]. Like usual I add the EPEL 
and [IUS Community][2] repositories so that I can have access to git 1.7, PHP 5.3,
MySQL 5.1, and Python 2.6 among other things. Everything was fine for 2 days until
I went to install a package today. A simple `yum install php53u-gd` resulted in a 
wall of 404 error messages when it tried to fetch some cryptic bzipped file:

{% highlight text %}
http://nas1.itc.virginia.edu/fedora-epel/5/x86_64/repodata/bd1da...-primary.sqlite.bz2: 
 [Errno 14] HTTP Error 404: Not Found
Trying other mirror.
Error: failure: 
repodata/bd1dac3a3d6ad62385741a9d50273ec1b2bcbd76-primary.sqlite.bz2 from
epel: [Errno 256] No more mirrors to try.
{% endhighlight %}

I tried repeatedly to clean the yum metadata and cache, even `yum clean all` a few times. The problem persisted.


### Troubleshooting ###

My first step was to actually look at [one of the mirrors][3] returning 404 and verify that the file
truly wasn't there. Sure enough, it wasn't. I also noted that they had recently been updated on 09-Feb-2011.

![centos mirror repodata](/images/updatedrepo.png)

I checked several other mirrors that were 404'ing and saw the same thing. Where was my machine fetching 
this information from? I asked around on IRC (#epel on freenode) and "nirik" suggested I try 
`URLGRABBER_DEBUG=1 yum update` which gave me the following output:

{% highlight text %}
INFO:urlgrabber:attempt 1/10: http://mirrors.servercentral.net/fedora/epel/5/x86_64/repodata/repomd.xml
INFO:urlgrabber:creating new connection to mirrors.servercentral.net (405445232)
INFO:urlgrabber:STATUS: 200, OK
INFO:urlgrabber:success
{% endhighlight %}

Navigating to the [ServerCentral EPEL mirror][4] showed me the problem.

![servercentral repodata](/images/repodata.png)

The `bd1dac3a3d6ad62385741a9d50273ec1b2bcbd76-primary.sqlite.bz2` was not here either, but what really caught my
eye was that the repo hadn't been updated since 27-Jan-2011.

YUM keeps a cache of the EPEL RPM database and assorted metadata in `/var/cache/yum/epel`. 
Checking this location on my system showed that I had the `bd1dac3a3d6ad62385741a9d50273ec1b2bcbd76-primary.sqlite.bz2`
file present. I also checked the contents of repomd.xml and found the root cause:

{% highlight xml %}
<data type="primary_db"> 
  <location href="repodata/bd1dac3a3d6ad62385741a9d50273ec1b2bcbd76-primary.sqlite.bz2"/> 
  <checksum type="sha">bd1dac3a3d6ad62385741a9d50273ec1b2bcbd76</checksum> 
  <timestamp>1296232850</timestamp> 
  <size>3646557</size> 
  <open-size>15332352</open-size> 
  <open-checksum type="sha">b75a93c694f8cbfacca64e4d145a03595775f785</open-checksum> 
  <database_version>10</database_version> 
</data>
{% endhighlight %}

Aha! Not only was the mirror out of date, but the repomd.xml was out of sync with the mirror itself.

### The Solution ###

CentOS is configured to use the fastestmirror yum plugin by default. My machine had an affinity for the
ServerCentral mirror because it was the fastest. To fix this I simply edit `/etc/yum/pluginconf.d/fastestmirror.conf`
adding an exclude as shown:

{% highlight ini %}
[main]
enabled=1
verbose=0
socket_timeout=3
hostfilepath=/var/cache/yum/timedhosts.txt
maxhostfileage=10
maxthreads=15
exclude=servercentral.net
{% endhighlight %}

Follow this up with a simple `yum clean dbcache metadata` and you're golden!

[1]: http://fedoraproject.org/wiki/EPEL
[2]: http://iuscommunity.org
[3]: http://nas1.itc.virginia.edu/fedora-epel/5/x86_64/repodata/
[4]: http://mirrors.servercentral.net/fedora/epel/