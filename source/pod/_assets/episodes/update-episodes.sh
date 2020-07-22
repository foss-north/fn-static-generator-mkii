#!/bin/bash

if [ -f "nextepisode" ]; then
	NEXT=$(cat nextepisode)
else
	NEXT="1"
fi

BEFORE=$(ls -l *.ogg | wc -l)

youtube-dl -x -f bestaudio --audio-format vorbis --yes-playlist 'https://www.youtube.com/playlist?list=PL8Xzb2qPbjDEad5--0M8W5TWEOgj_yo1z' --playlist-start=$NEXT --playlist-end=$NEXT --output "%(title)s.%(ext)s" --write-info-json

AFTER=$(ls -l *.ogg | wc -l)

NNEXT=$(expr $NEXT + 1)

if [ "$BEFORE" -ne "$AFTER" ]; then
    YAML_TITLE=$(cat *.info.json | python -m json.tool | grep '\"title\"' | head -n1 | cut -d ':' -f 2 | sed 's/\",.*$//' | sed 's/^.*\"//' | sed 's/[0-9]* - //')
    YAML_YT=$(cat *.info.json | python -m json.tool | grep '\"id\"' | head -n1 | cut -d ':' -f 2 | sed 's/\",.*$//' | sed 's/^.*\"//')
    YAML_OGG="$(cat *.info.json | python -m json.tool | grep '\"title\"' | head -n1 | cut -d ':' -f 2 | sed 's/\",.*$//' | sed 's/^.*\"//').ogg"
    YAML_MP3="$(basename "$YAML_OGG" .ogg).mp3"
    YAML_PUBDATE=$(date "+%a, %d %b %Y %X %z")
    YAML_NUMBER=$(cat *.info.json | python -m json.tool | grep '\"title\"' | head -n1 | cut -d ':' -f 2 | sed 's/\",.*$//' | sed 's/^.*\"//' | sed 's/ -.*//' | sed 's/^0*//')
    YAML_DESCRIPTION=$(cat *.info.json | python -m json.tool | grep '\"description\"' | head -n1 | cut -d ':' -f 2 | sed 's/\",.*$//' | sed 's/^.*\"//' | sed 's/Visit.*//')

    ffmpeg -i "$YAML_OGG" "$YAML_MP3"
    
    YAML_OGG_SIZE=$(stat -c %s "$YAML_OGG")
    YAML_MP3_SIZE=$(stat -c %s "$YAML_MP3")
    
    TOTAL_DURATION_MS=$(mediainfo --Inform="General;%Duration%" "$YAML_OGG")
    TOTAL_DURATION_S=$(expr $TOTAL_DURATION_MS / 1000)
    DURATION_S=$(expr $TOTAL_DURATION_S % 60)
    TOTAL_DURATION_M=$(expr $TOTAL_DURATION_S / 60)
    DURATION_H=$(expr $TOTAL_DURATION_M / 60)
    DURATION_M=$(expr $TOTAL_DURATION_M % 60)
    YAML_DURATION=$(printf "%02d:%02d:%02d" $DURATION_H $DURATION_M $DURATION_S)
	
    echo "" >> ../_data/episodes.yaml
	echo "- title: \"$YAML_TITLE\"" >> ../_data/episodes.yaml
	echo "  yt: \"$YAML_YT\"" >> ../_data/episodes.yaml
	echo "  ogg: \"$YAML_OGG\"" >> ../_data/episodes.yaml
	echo "  mp3: \"$YAML_MP3\"" >> ../_data/episodes.yaml
	echo "  oggsize: $YAML_OGG_SIZE" >> ../_data/episodes.yaml
	echo "  mp3size: $YAML_MP3_SIZE" >> ../_data/episodes.yaml
	echo "  duration: \"$YAML_DURATION\"" >> ../_data/episodes.yaml
	echo "  pubdate: \"$YAML_PUBDATE\"" >> ../_data/episodes.yaml
	echo "  number: $YAML_NUMBER" >> ../_data/episodes.yaml
	echo "  description: \"$YAML_DESCRIPTION\"" >> ../_data/episodes.yaml
	
	rm *.info.json
	echo "$NNEXT" > nextepisode
fi

