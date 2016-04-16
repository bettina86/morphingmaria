#!/bin/bash

cd "$(dirname "$0")"
while inotifywait -r assets -e CLOSE_WRITE -qq ; do
  haxelib run lime update neko
done
