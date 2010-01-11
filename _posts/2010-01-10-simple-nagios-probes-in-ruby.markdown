---
layout: post
title: Simple Nagios probes in ruby
---
I needed to write a custom nagios probe a few weeks ago. I googled for existing solutions in Ruby, but surprisingly
found none. A nagios probe can really be written in any language, it just has to return a single line of output and
an exit code of 0 (OK), 1 (WARNING), 2 (CRITICAL), or 3 (UNKNOWN). I chose Ruby because of the syntactical simplicity,
as well as the ease of bundling it as a gem using [Gemcutter][1].

You can view the source [here][2].

### Installation

    # gem install nagios-probe
    
### Usage

Simply create a subclass of Nagios::Probe and define the following methods:

* check_crit
* check_warn
* check_ok (optional - it is defined in the base class to always return true)
* crit_message
* warn_message
* ok_message

#### Example

{% highlight ruby %}
class MyProbe < Nagios::Probe
  def check_crit
    true
  end

  def check_warn
    false
  end

  def crit_message
    "Things are bad"
  end

  def warn_message
    "Things aren't going well"
  end

  def ok_message
    "Nothing to see here"
  end
end
{% endhighlight %}
    
To use your probe you **must** wrap it in a begin/rescue block to catch any exceptions and accurately report the status
to Nagios.

{% highlight ruby %}
begin
  options = {} # constructor accepts a single optional param that is assigned to @opts
  probe = MyProbe.new(options)
  probe.run
rescue Exception => e
  puts "Unknown: " + e
  exit Nagios::UNKNOWN
end

puts probe.message
exit probe.retval
{% endhighlight %}

[1]: http://gems.rubyforge.org/
[2]: http://github.com/hobodave/nagios-probe