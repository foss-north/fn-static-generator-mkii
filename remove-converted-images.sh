#!/bin/bash

echo "This script removes all pngs in the _assets that have a name collision with a generated png."
echo
echo "    *** USE WITH EXTREME CARE ***"
echo 
echo "Press CTRL-C to abort, any other key continues"
read -n 1

set -e

for conversion in $(cat image-conversions.conf); do
  if [ $(echo "$conversion" | cut -c1) != "#" ]; then
    scope=$(echo "$conversion" | cut -d: -f1 -)
    original=$(echo "$conversion" | cut -d: -f2 -)
    destination=$(echo "$conversion" | cut -d: -f3 -)
    size=$(echo "$conversion" | cut -d: -f4 -)
    echo "Cleaning up $scope::$original"
    
    for f in source/$scope/$original; do
        filename=$(basename "$f")
        filebase="${filename%.*}"
        destfile="source/$scope/$destination$filebase.png"
        echo "  Removing $destfile"
        rm -f $destfile
    done
  fi
done
