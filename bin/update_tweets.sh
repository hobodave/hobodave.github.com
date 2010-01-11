#!/bin/bash

RUBY=/usr/bin/ruby

RELDIR=`dirname $0`
cd $RELDIR/..

BASEDIR=`pwd`

$RUBY ${BASEDIR}/bin/twit.rb > ${BASEDIR}/_includes/twitter.html

git reset HEAD .
git commit -a -m "Automatic tweet update" _includes/twitter.html
git stash
git push
git stash apply