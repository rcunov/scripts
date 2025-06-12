#!/bin/bash

for i in *.flac; do
  docker run -v "$(pwd)":"$(pwd)" -w "$(pwd)" jrottenberg/ffmpeg:7-scratch -i "$i" -vcodec copy -acodec libfdk_aac -vbr 3 "${i%.*}.m4a"
done
