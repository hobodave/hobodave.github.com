---
layout: post
title: PhpGhettoDoc - Document your PHP w/ ruby?
---

In a moment of boredom I decided I needed a simple way to document a giant batch of PHP files with skeleton
PhpDocblocks. PHP not being my first language, I decided why not do it in ruby. I find ruby scripting to be
quick, fast enough, and it has lots of great easy to use modules (e.g., [Find][1].)

That said, here she is:

{% highlight ruby %}
#!/usr/bin/env ruby
require 'ftools'
require 'optparse'
require 'find'

class PhpGhettoDoc

  Class_Doc = <<-EOF

/**
 * Undocumented class.
 *
 * @todo document me
 * @package unknown
 * @author unknown
 **/
EOF

  Function_Doc = <<-EOF

/**
 * Undocumented function.
 *
 * @todo document me
 * @return void
 * @author unknown
 **/
EOF

  Const_Doc = <<-EOF

/**
 * Undocumented constant.
 * @todo document me
 **/
EOF

  Var_Doc = <<-EOF

/**
 * Undocumented variable
 * @todo document me
 **/
EOF

  def initialize(file, backup = true)
    @backup = backup
    @word_matcher = /^(\s*)(class|const|function|public|interface|final|protected|private|static)+\s+([$\w]+)[\t ]*(\w+)*/
    @doc_matcher = /^\s*(\*|\/)+/

    @doc_blocks = {:class    => Class_Doc,
                   :function => Function_Doc,
                   :const    => Const_Doc,
                   :abstract  => Class_Doc,
                   :final     => Class_Doc,
                   :interface => Class_Doc,
                   :var       => Var_Doc}

    @file = file
    @dirty_lines = File.open(file, 'r+').readlines
    @modified = false
  end

  def parse_lines
    @clean_lines = Array.new
    @dirty_lines.each do |line|
      if (line.match @word_matcher)
        indent = $1
        keywords = ($4) ? Array[$2.intern, $3.intern, $4.intern] : Array[$2.intern, $3.intern]
        case $2.intern
          when :public, :protected, :private, :static
            type = (keywords.include? :function) ? :function : :var
          else
            type = $2.intern
        end
        unless (@clean_lines.last =~ @doc_matcher || !type)
          doc_block = @doc_blocks[type]
          @clean_lines.push(doc_block.split("\n").map! { |l| l = indent + l }.join("\n") + "\n");
          @modified = true
        end
      end
      @clean_lines.push line
    end
  end

  def dump
    @clean_lines.each do |line|
      puts line
    end
  end

  def save
    if @modified
      if @backup
        File.move(@file, @file + '.bak.' + Time.now.strftime("%Y%m%d%H%M%S"))
      end
      f = File.new(@file, "w")
      @clean_lines.each { |line| f.write(line) }
      f.close
    end
    @modified
  end
end

if $0 == __FILE__
  options = { :save => false, :backup => false, :recurse => false }
  usage = "usage: #{__FILE__} [options] <file|directory>"
  OptionParser.new do |opts|
    opts.banner = usage
    opts.on('-s', '--save', "Saves the parsed file to disk. (Default: false)") do |s|
      options[:save] = s
    end
    opts.on('-b', '--[no-]backup', 'Create backups. (Default: false)') do |b|
      options[:backup] = b
    end
    opts.on('-r', '--recurse', 'Recurse subdirectories. (Default: false)') do |r|
      options[:recurse] = r
    end
  end.parse!

  unless ARGV.length >= 1
    puts usage
    exit
  end

  modified = 0
  files = Array.new
  if File.directory?(ARGV[0])
    Find.find(ARGV[0]) do |path|
      if (FileTest.directory?(path))
        if (File.basename(path)[0] == ?. && path != '.')
          Find.prune    # Skip .foo directories
        elsif (! options[:recurse] && ARGV[0] != path)
          Find.prune    # Skip recurse
        else
          next
        end
      else
        if path =~ /.php$/
          files.push path
        end
      end
    end
  else
    files.push ARGV[0]
  end

  files.each do |file|
    p = PhpGhettoDoc.new(file, options[:backup])
    p.parse_lines
    if options[:save]
      modified += (p.save) ? 1 : 0
    else
      p.dump
    end
  end

  puts "Processed #{files.size} files"
  puts "Modified #{modified} files"
end
{% endhighlight %}

[1]: http://ruby-doc.org/core/classes/Find.html "Ruby Find module"