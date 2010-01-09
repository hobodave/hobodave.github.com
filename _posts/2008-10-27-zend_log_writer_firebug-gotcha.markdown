---
layout: post
title: Zend_Log_Writer_Firebug gotcha_
---
A few weeks ago I found a gem of a class called [Zend_Log_Writer_Firebug][1] within [Zend Framework][2]. It really is
a **must have** when it comes to debug logging.

However, a few weeks ago something bizarre happened that caused all of my [FirePHP][3] logging to break. I scoured the
web for bug reports to find issues _similar_ but not quite the same. I wasn't using AJAX calls, and I could see the
[FirePHP][3] headers in the response headers of FireBug, but I couldn't see the formatted output.

I finally got fed up today. I hate var_dump's and wanted my FirePHP logging back. After a near flying knee to my
computer screen, I figured it out.

It appears that I was using FirePHP v0.1.2, and the latest was 0.2. For reasons beyond my knowledge, [Firefox][4]
wasn't detecting this as needing an upgrade.

After upgrading to 0.2 my FirePHP log messages worked again! I hope this shaves a few days of someone's
frustrations.


[1]: http://framework.zend.com/manual/en/zend.log.writers.html#zend.log.writers.firebug "Zend_Log_Writer_Firebug"
[2]: http://framework.zend.com/ "Zend Framework"
[3]: http://www.firephp.org/ "FirePHP"
[4]: http://getfirefox.com/ "Firefox"