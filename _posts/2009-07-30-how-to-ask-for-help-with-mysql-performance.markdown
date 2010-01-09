---
layout: post
title: How to ask for help with MySQL performance
---

<p class="large quiet">{{ page.date | date_to_string }}</p>

Since discovering [StackOverflow][1] I've become hopelessly addicted (<strike>see the badge to the right</strike>). 
I answer the [mysql][2], [php][3], [zend-framework][4], and [javascript][5] categories mostly.

My favorite category is [mysql][2]. These can be some of the most challenging questions to answer, particularly the
query optimization ones. I often answer, having learned something myself in the process.

Unfortunately, given the vast number of users, there are a lot of communication inconsistencies. It drives me 
batshit-crazy to read a textual description of a table. So I created a simple guide to getting people to help you with
MySQL queries.

* **SHOW CREATE TABLE** - this is the best way to show someone your table schema. Don't try to describe it using 
  plain-English, it just isn't good enough. This exposes your columns, field types (you said TIMESTAMP but you really
  have a DATETIME), and your indices all in one query.
* **USE EXPLAIN** - EXPLAINing your queries shows others where to start. It's ok if you don't understand it completely,
  but read the [documentation][6] for the basics.
* **USE \G** - You have two ways to delimit your MySQL queries when using the mysql client. Using the DELIMITER, ; by 
  default - or using **\G**. This turns your columnar data into row data and limits the width to 80 chars. This is
  ideal for displaying on the web.

Read the [full article][7] on StackOverflow.

[1]: http://stackoverflow.com/ "StackOverflow"
[2]: http://stackoverflow.com/questions/tagged/mysql
[3]: http://stackoverflow.com/questions/tagged/php
[4]: http://stackoverflow.com/questions/tagged/zend-framework
[5]: http://stackoverflow.com/questions/tagged/javascript
[6]: http://dev.mysql.com/doc/refman/5.1/en/using-explain.html
[7]: http://stackoverflow.com/questions/1204402/how-do-i-ask-for-help-optimizing-fixing-queries-in-mysql