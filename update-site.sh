#!/bin/sh

./convert-images.sh

for s in source/*; do
    d=$(echo $s|sed 's/^source/build/')
    ./fn-generator.py "$s" "$d"
done
