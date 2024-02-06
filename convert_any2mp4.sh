#!/bin/bash
# данный скрипт конвертирует все видеофайлы в формат mp4
# с видеокодеком libx264 и аудиокодеком aac

function convertFile {
  # $1 - исходный файл
  # $2 - результирующий файл
  ffmpeg -nostdin -i "$1" -c:v mpeg4 -c:a aac "$2";
}

if ! command -v basename &> /dev/null
then
    echo "basename could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v ls &> /dev/null
then
    echo "ls could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v realpath &> /dev/null
then
    echo "realpath could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v sort &> /dev/null
then
    echo "sort could not be found"
    echo "You must install it before run this script."
    exit 1
fi

source="./dest";
dest="./dest_mp4";

for FILE in $(ls -1 "$(realpath "$source")" | sort -n -t _ -k 2) ; do
  filename="$(realpath "$source")/$FILE";
  baseName=${FILE%.*};
  ext=".mp4";
  destFilename="$(realpath "$dest")/$baseName$ext";
  echo "Converting $filename";
  convertFile "$filename" "$destFilename";
  echo "Successfully filtered $filename into $destFilename";
  echo;
done
echo "All done!"
echo;
