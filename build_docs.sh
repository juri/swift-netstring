#!/bin/sh

git submodule update --remote

cd swift-netstring

jazzy --swift-version 3.1 -o .. \
      --readme README.md \
      -a 'Juri Pakaste' \
      -u 'https://twitter.com/juripakaste' \
      -g 'https://github.com/juri/swift-netstring'

