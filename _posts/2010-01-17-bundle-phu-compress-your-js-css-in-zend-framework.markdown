---
layout: post
title: bundle-phu - minify, bundle, and compress your js/css in Zend Framework
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
that do all of the above.

Bundle-phu is inspired by, [bundle-fu][4] a Ruby on Rails equivalent.

### Before

    {% highlight html %}
    <script type="text/javascript" src="/js/jquery.js"></script>
    <script type="text/javascript" src="/js/foo.js"></script>
    <script type="text/javascript" src="/js/bar.js"></script>
    <script type="text/javascript" src="/js/baz.js"></script>
    <link media="screen" type="text/css" href="/css/jquery.css" />
    <link media="screen" type="text/css" href="/css/foo.css" />
    <link media="screen" type="text/css" href="/css/bar.css" />
    <link media="screen" type="text/css" href="/css/baz.css" />
    {% endhighlight %}
    
### After

    {% highlight html %}
    <script type="text/javascript" src="bundle_3f8ca8371a8203fcdd8a82.css?1234567890"></script>
    <link type="text/css" src="bundle_3f8ca8371a8203fcdd8a82.css?1234567890"></script>
    {% endhighlight %}

### Highlights

* Changes to your source js/css is detected, and bundles regenerated automatically
* Minification can be done using either an external program ([YUI compressor][5]), or
via callback in PHP.
* Compression is achieved using [gzencode()][6]

### Installation

1. Place the BundlePhu directory somewhere in your include_path:

        your_project/
        |-- application
        |-- library
        |   `-- BundlePhu
        |-- public

2. Add the BundlePhu view helpers to your view's helper path, and configure the helpers:

        {% highlight php %}
        <?php
        class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
        {
            protected function _initView()
            {
                $view = new Zend_View();
                $view->addHelperPath(
                    PATH_PROJECT . '/library/BundlePhu/View/Helper',
                    'BundlePhu_View_Helper'
                );

                $view->getHelper('BundleScript')
                    ->setCacheDir(PATH_PROJECT . '/data/cache/js')
                    ->setDocRoot(PATH_PROJECT . '/public')
                    ->setUseMinify(true)
                    ->setMinifyCommand('java -jar yuicompressor -o :filename)
                    ->setUseGzip(true)
                    ->setGzipLevel(9)
                    ->setUrlPrefix('/javascripts');

                $view->getHelper('BundleLink')
                    ->setCacheDir(PATH_PROJECT . '/data/cache/css')
                    ->setDocRoot(PATH_PROJECT . '/public')
                    ->setUrlPrefix('/javascripts');

                $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
                $viewRenderer->setView($view);
                return $view;
            }
        }
        {% endhighlight %}

3.  Ensure your CacheDir is writable by the user your web server runs as
4.  Using either an Alias (apache) or location/alias (nginx) map the UrlPrefix to CacheDir.
    You can also do this using a symlink from your /public directory.
    e.g. /public/javascripts -> /../data/cache/js

### Usage

As both these helpers extend from the existing HeadScript and HeadLink helpers in [Zend Framework][1],
you can use them just as you do those.
  
    {% highlight php %}
    <? $this->bundleScript()->offsetSetFile(00, $this->baseUrl('/js/jquery.js')) ?>
    <? $this->bundleScript()->appendFile($this->baseUrl('/js/foo.js')) ?>
    {% endhighlight %}


[1]: http://github.com/hobodave/bundle-phu
[2]: http://framework.zend.com/
[3]: http://github.com/hobodave/bundle-phu/issues
[4]: http://code.google.com/p/bundle-fu/
[5]: http://developer.yahoo.com/yui/compressor/
[6]: http://php.net/gzencode