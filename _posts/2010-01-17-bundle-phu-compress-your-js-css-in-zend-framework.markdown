---
layout: post
title: bundle-phu: minify, bundle, and compress your js/css in Zend Framework
tags: [zend framework, css, javascript, bundle-phu]
---

I've used a few different CSS/JS bundlers, but none have ever fulfilled _all_ 
that I needed. Specifically, I wanted one that could do all of the following:

* Bundle automatically with little configuration
* Optionally minify
* Optionally compress
* Allow the bundled files to be served directly by the webserver, instead of 
by PHP.
* Easily allow files to be served compressed, but without recompressing on every request
* Automatically detect modification the the source files, and update bundles as needed.

Thus, I created [bundle-phu][1]. Bundle-phu is a set of [Zend Framework][2] view helpers
that do all of the above. Bundle-phu is inspired by, and the name is stolen and mangled
from [bundle-fu][4] a Ruby on Rails equivalent.

Please see the README on [github] for Usage and Installation
instructions. Feel free to ask any questions in the comments, or use the [issue tracker][3]
to report bugs.

[1]: http://github.com/hobodave/bundle-phu
[2]: http://framework.zend.com/
[3]: http://github.com/hobodave/bundle-phu/issues
[4]: http://code.google.com/p/bundle-fu/