#!/bin/bash

middleman build
cd build
git add .
git commit -am "build"
git push origin master