#!/bin/bash

set -e

dirfilter="---"

while [[ $# -gt 0 ]]; do

    key="$1"
    shift

    case "$key" in
        "--dir"|"--dirs")
            dirfilter="$1"
            shift
            ;;
        *)
            echo "Unknown argument '$key'"
            exit 1
            ;;
    esac
done



for conversion in $(cat image-conversions.conf); do
  if [ $(echo "$conversion" | cut -c1) != "#" ]; then
    scope=$(echo "$conversion" | cut -d: -f1 -)
    original=$(echo "$conversion" | cut -d: -f2 -)
    destination=$(echo "$conversion" | cut -d: -f3 -)
    size=$(echo "$conversion" | cut -d: -f4 -)
    echo "Converting $scope::$original"

    if [[ dirfilter != "---" ]]; then
        found="no"
        for d in $dirfilter; do
            if [[ "$scope" == "$d" ]]; then
                found="yes"
            fi
        done
        if [[ "$found" == "no" ]]; then
            continue
        fi
    fi
    
    for f in source/$scope/$original; do
        filename=$(basename "$f")
        filebase="${filename%.*}"
        destfile="source/$scope/$destination$filebase.png"
        echo "  $f => $destfile"
        convert $f -resize $size -background transparent -gravity center -extent $size $destfile
    done
  fi
done
