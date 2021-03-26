#!/bin/bash

images="yes"
dirs="source/*"
dirnames="---"

while [[ $# -gt 0 ]]; do

    key="$1"
    shift

    case "$key" in
        "--no-images")
            images="no"
            ;;
        "--dir"|"--dirs")
            dirs="source/$1"
            dirnames="$1"
            shift
            ;;
        *)
            echo "Unknown argument '$key'"
            exit 1
            ;;
    esac
done

if [ "$images" = "yes" ]; then
    if [[ "$dirnames" == "---" ]]; then
        ./convert-images.sh
    else
        ./convert-images.sh --dirs "$dirnames"
    fi
fi

echo $dirs
for s in $dirs; do
    echo "--> $s"
done

exit 0

for s in $dirs; do
    if [ -f $s/update.sh ]; then
        pushd "$s"
        ./update.sh
        popd
    fi

    d=$(echo $s|sed 's/^source/build/')
    ./fn-generator.py "$s" "$d"
done
