#!/bin/bash

# First positional arg is a geometry (480x720) or percentage reduction (50%)
# Every other arg is a file to be resized
# Example:
# $ resize-images 50% *.jpg
mkdir -p resized
for file in "${@:2}";
do
    convert -resize "${1}" "${file}" "resized/${file}"
done
