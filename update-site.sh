#!/bin/bash

images="yes"
if [ "$#" -eq "1" ]; then
    case "$1" in
        "--no-images")
            images="no"
            ;;
        *)
            echo "Unknown argument '$1'"
            exit 1
            ;;
    esac
fi

if [ "$images" = "yes" ]; then
    ./convert-images.sh
fi

for s in source/*; do
    if [ -f $s/update.sh ]; then
        pushd "$s"
        ./update.sh
        popd
    fi

    d=$(echo $s|sed 's/^source/build/')
    ./fn-generator.py "$s" "$d"
done
