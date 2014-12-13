#!/bin/bash

git push origin master

bundle exec middleman build
cd build
git add .
git commit -am "build"
git push -f origin master
