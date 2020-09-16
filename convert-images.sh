#!/bin/bash

set -e

for conversion in $(cat image-conversions.conf); do
  if [ $(echo "$conversion" | cut -c1) != "#" ]; then
    scope=$(echo "$conversion" | cut -d: -f1 -)
    original=$(echo "$conversion" | cut -d: -f2 -)
    destination=$(echo "$conversion" | cut -d: -f3 -)
    size=$(echo "$conversion" | cut -d: -f4 -)
    echo "Converting $scope::$original"
    
    for f in source/$scope/$original; do
        filename=$(basename "$f")
        filebase="${filename%.*}"
        destfile="source/$scope/$destination$filebase.png"
        echo "  $f => $destfile"
        convert $f -resize $size -background transparent -gravity center -extent $size $destfile
    done
  fi
done
