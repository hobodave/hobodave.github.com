---
layout: post
title: Spell check with Zend_Json_Server & pspell
---
An application I've been working on has had a desire for spell check capabilities for some time now. As most browsers
provide native methods for this, it has remained on the back burner until now.

I decided to use [Zend_Json_Server][1] for a few reasons:

1. I wanted to avoid the overhead required to bootstrap and route requests in my MVC [Zend_Framework][2] app
2. I wanted to tinker with Zend's easy to use JSON-RPC magic
3. I try to avoid XML, and thus [XML-RPC][3], as much as possible

### Requirements

Your server _requires_ the following for the JSON-RPC server to work:

* [Zend Framework][2] = 1.7
* [pspell][4]

To use the javascript client (optional):

* [Prototype][5] = 1.6

### Files

#### SpellCheck.php

{% highlight php %}
<?php
/**
 * SpellCheck
 *
 * LICENSE
 *
 * This source file is subject to the new BSD license that is bundled
 * with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://hobodave.com/license.txt
 *
 * @package    SpellCheck
 * @copyright  Copyright (c) 2008-2009 David Abdemoulaie (http://hobodave.com/)
 * @license    http://hobodave.com/license.txt New BSD License
 */
class SpellCheck
{
    protected function __construct()
    {
        $this->_getDict();
    }

    public function check($word)
    {
        $dict = $this->_getDict();
        return pspell_check($dict, $word);
    }

    public function suggest($word)
    {
        $dict = $this->_getDict();
        return pspell_suggest($dict, $word);
    }

    public function checktext($text)
    {
        $dict = $this->_getDict();
        $matches = array();

        $result = array(
            'c' => array()
        );

        preg_match_all(
            '/\w+/',
            $text,
            $matches,
            PREG_OFFSET_CAPTURE|PREG_PATTERN_ORDER);
        foreach($matches[0] as $match) {
            if (pspell_check($dict,$match[0])) {
                continue;
            }
            $suggestions = pspell_suggest($dict,$match[0]);

            $correction = array(
                'o' => $match[1],
                'l' => strlen($match[0]),
                't' => array_slice($suggestions, 0, 5)
            );
            $result['c'][] = $correction;
        }

        return $result;
    }

    protected function _getDict()
    {
        if ($this->_dict === null) {
            $this->_dict = pspell_new('en', '', '', '', PSPELL_FAST);
        }
        return $this->_dict;
    }
}
?>
{% endhighlight %}

This class exposes three methods via the JSON-RPC interface: **check**, **suggest**, and **checkText**. As you can see,
check and suggest are simple wrappers for [pspell_check][6] and [pspell_suggest][7] respectively. They each operate on
only a single word.

The **checkText** method combines the features of both check and suggest, and works on strings consisting of an
arbitrary number of words. It also returns an object detailing all the spelling errors found, as well as the top five
suggestions for them.

#### json-rpc.php

{% highlight php %}
<?php
set_include_path('./lib:.');

include 'lib/Zend/Loader.php';
Zend_Loader::registerAutoload();

$server = new Zend_Json_Server();
$server->setClass('SpellCheck');
if ('GET' == $_SERVER['REQUEST_METHOD']) {
    $server->setTarget('/spell/json-rpc.php')
           ->setEnvelope(Zend_Json_Server_Smd::ENV_JSONRPC_2);

    $smd = $server->getServiceMap();

    header('Content-Type: application/json-rpc');
    echo $smd;
    return;
}

$server->handle();
?>
{% endhighlight %}

This is the wonderfully simple class that sets up our Zend_Json_Server and handles requests. I love that Zend_Json
allows me to do this in only 20 lines of code.

#### spellcheck.js (optional)

{% highlight javascript %}
var SpellChecker = Class.create({
  initialize: function(url, callback, options) {
    this.url = url;
    this.callback = callback;
    this.options = {
      rpcRequest: {
          jsonrpc:"2.0",
          method:"",
          params: [],
          id: Math.floor(Math.random() * 100)
      },
      request: {
          method: "post",
          contentType: "application/json-rpc",
          requestHeaders: { Accept: "application/json-rpc" },
          onSuccess: callback
      }
    }
    Object.extend(this.options,options || {});
  },
  check: function(word) {
    rpcRequest = Object.extend(Object.clone(this.options.rpcRequest), {method:"check",params:[word]});
    this.sendRequest(rpcRequest);
  },
  suggest: function(word) {
    rpcRequest = Object.extend(Object.clone(this.options.rpcRequest), {method:"suggest",params:[word]});
    this.sendRequest(rpcRequest);
  },
  checkText: function(text) {
    rpcRequest = Object.extend(Object.clone(this.options.rpcRequest), {method:"checktext",params:[text]});
    this.sendRequest(rpcRequest);
  },
  sendRequest: function(request) {
    ajaxOptions = Object.extend(Object.clone(this.options.request), {
        postBody: Object.toJSON(request)
    })
    new Ajax.Request(this.url, ajaxOptions);
  }
})
{% endhighlight %}

### Usage

The usage examples will assume you are using the Prototype client shown above, though any client could be used. They
also assume you have firebug installed, and thus can use the console.log() method.

#### Example 1

{% highlight javascript %}
var fb = function(transport) {
  console.log(transport.responseJSON);
}
var sc = new SpellChecker('/spell/json-rpc.php', fb);
sc.check('sevne');
{% endhighlight %}

This checks if the word 'sevne' is a properly spelled word.

#### Output

{% highlight javascript %}
{
  "result":false,
  "id":"48",
  "jsonrpc":"2.0"
}
{% endhighlight %}

The output shows that the result is *false*, it is not a correctly spelled word.

#### Example 2

{% highlight javascript %}
sc.suggest('sevne');
{% endhighlight %}

This asks for suggested spellings for 'sevne'.

#### Output

{% highlight javascript %}
{
  "result": ["seven","Sven","Severn","Seine","seine","Steven","scene","seen","Even","even","serve","serving"
,"sever","sieve","sieving","sevens","Sen","Sivan","Svend","sen","Keven","semen","seiner","Levine","Selene"
,"Seline","Serene","Sterne","serene","severe","Savina","Sean","Sena","sane","save","saving","sewn","sine"
,"Ferne","Seana","senna","Sven's","seven's"],
  "id":"48",
  "jsonrpc":"2.0"
}
{% endhighlight %}

In this case the **result** is an array of the forty most likely substitutes for this word.

#### Example 3

{% highlight javascript %}
sc.checkText('Four score and sevne years ago our fathres brought forth on this continnent a new nation.');
{% endhighlight %}

This is likely the most useful usage of all, as it avoids the need for multiple calls to the server.

#### Output

{% highlight javascript %}
{"result": {"c": [
  {"o":15,"l":5,"t":["seven","Sven","Severn","Seine","seine"]},
  {"o":35,"l":7,"t":["Fathers","fathers","Father's","father's","feathers"]},
  {"o":65,"l":10,"t":["Continent","continent","contingent","containment","continents"]}]},
"id":"48","jsonrpc":"2.0"}
{% endhighlight %}

The result in this case is a slightly more complex JSON Object than the other examples.

I'll do my best to explain this clearly.

* result is a JSON _Object_ with a single property 'c' (corrections).
* result.c is an _Array_ of corrections
* each correction is an _Object_ with the following properties

<table border="1px" cellspacing="0" cellpadding="0">
  <tr><th>Property</th><th>Description</th></tr>
  <tr><td><strong>o</strong></td><td>The offset of the misspelled word from the beginning of the text</td></tr>
  <tr><td><strong>l</strong></td><td>The length of the misspelled word</td></tr>
  <tr><td><strong>t</strong></td><td>An <em>Array</em> of the <em>top five</em> suggestions for the misspelled word</td></tr>
</table>

The syntax of the **checkText** method was inspired by Google's spell check API that is part of the Google Toolbar.
My thanks to [Paul Welter][8] for reverse engineering it and posting the results.

### Conclusion

This wraps up my fun, though admittedly simple, example of Zend_Json. (I think I spent more time on this blog post than the actual code).

[1]: http://framework.zend.com/manual/en/zend.json.server.html "Zend Json Server"
[2]: http://framework.zend.com/ "Zend Framework"
[3]: http://framework.zend.com/manual/en/zend.xmlrpc.html "Zend XML-RPC"
[4]: http://us3.php.net/manual/en/book.pspell.php "pspell"
[5]: http://www.prototypejs.org/ "prototype"
[6]: http://us3.php.net/manual/en/function.pspell-check.php "pspell_check"
[7]: http://us3.php.net/manual/en/function.pspell-suggest.php "pspell_suggest"
[8]: http://weblogs.asp.net/pwelter34/archive/2005/07/19/419838.aspx "Paul Welter"