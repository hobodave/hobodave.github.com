require 'rubygems'
require 'twitter'

twitter_user = 'hobodave'

puts '<ul id="twitter_list" class="pull-1">'

Twitter::Search.new.from(twitter_user).each do |r|
  d = DateTime.parse(r.created_at).strftime('%d %b')
  puts "<li><span class=\"gentle\">#{d}</span> #{r.text} <a href=\"http://twitter.com/#{twitter_user}/status/#{r.id}\">#</a></li>"
end

puts '</ul>'

