#!/bin/bash

RUBY=/usr/bin/ruby
GIT=/opt/local/bin/git

RELDIR=`dirname $0`
cd $RELDIR/..

BASEDIR=`pwd`

$RUBY ${BASEDIR}/bin/twit.rb > ${BASEDIR}/_includes/twitter.html

eval $(ssh-agent)
$GIT reset HEAD .
$GIT add _includes/twitter.html
$GIT commit -m "Automatic tweet update" _includes/twitter.html
$GIT stash
$GIT push
$GIT stash apply
