#!/bin/bash
# данный скрипт берет один кадр с заданным временем из видео, сохраняя его в картинку

# $1 - путь к видео
# $2 - временная отметка кадра
# $3 - куда сохранить кадр

if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found"
    echo "You must install it before run this script."
    exit 1
fi

rm -rf "$3" >/dev/null 2>&1;
ffmpeg -nostdin -ss "$2" -i "$1" -vframes 1 "$3";