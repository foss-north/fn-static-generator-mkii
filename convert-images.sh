#!/bin/bash

set -e

dirfilter="---"
onlynew=""

while [[ $# -gt 0 ]]; do

    key="$1"
    shift

    case "$key" in
        "--dir"|"--dirs")
            dirfilter="$1"
            shift
            ;;
        "--only-new")
            onlynew=true
            ;;
        *)
            echo "Unknown argument '$key'"
            exit 1
            ;;
    esac
done



for conversion in $(cat image-conversions.conf); do
  if [ "$(echo "$conversion" | cut -c1)" != "#" ]; then
    scope=$(echo "$conversion" | cut -d: -f1 -)
    original=$(echo "$conversion" | cut -d: -f2 -)
    destination=$(echo "$conversion" | cut -d: -f3 -)
    size=$(echo "$conversion" | cut -d: -f4 -)
    echo "Converting $scope::$original"

    if [[ "$dirfilter" != "---" ]]; then
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

        if [ -n "$onlynew" ] && [ -f "$destfile" ]; then
            continue
        fi

        colorspace="sRGB"
        fileparent="$(basename "$(dirname "$f")")"
        if [[ $fileparent == "speakers" ]]; then
            colorspace="Gray"
        fi

        echo "  $f => $destfile"
        convert "$f" \
            -resize "$size" \
            -colorspace "$colorspace" \
            -background transparent \
            -gravity center \
            -auto-orient \
            -extent "$size" \
            "$destfile"
    done
  fi
done
