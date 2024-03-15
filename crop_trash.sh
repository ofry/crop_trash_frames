#!/bin/bash
# данный скрипт пытается выкинуть все "плохие" фреймы из видеофайлов
# с повторной склейкой обрезков

function clearDir {
  # $1 - путь к очищаемой папке
  # сохраняем только скрытые файлы

  for FILE in "$(realpath "$1")"/* ; do
    rm -rf "$FILE";
  done
}

function makeGoodParts {
# данная функция ищет все "хорошие" интервалы видеофайла
# т.е. не совпадающие с "плохим" кадром
# и режет исходный файл на соответствующие фрагменты
# $1 - путь к исходному видеофайлу
# $2 - путь к папке с "плохими" кадрами
# $3 - путь к временной папке для хранения фрагментов
# $4 - битрейт видео

  for bad_frame in $(ls -1 "$(realpath "$2")" | sort -n -t _ -k 2) ; do
    # echo "$(realpath "$3")"/"$(basename "$1")"_"$bad_frame".log;
    # строится список кадров и указывается процент совпадения с "плохим" кадром
    ffmpeg -nostdin -an -i "$1" -loop 1 -i "$(realpath "$2")"/"$bad_frame" \
          -filter_complex "blend=difference:shortest=1,blackframe=0" -f null - 2>&1 | \
    # выбираем только нужные строки
           grep '^\[Parsed_blackframe_1' | \
    # избавляемся от лишних данных
           awk '{print $4, $5, $6, $7, $9}' | \
           tr ':' ' ' | \
    # выбираем только "хорошие" кадры (степень совпадения с "плохим" кадром меньше 80%)
           awk '{if ($4 < 80) {print $1, $2, $5, $6, $7, $8, $9, $10}}' >"$(realpath "$3")"/"$(basename "$1")"_"$bad_frame".log;
  done
 ./good_frame_list.sh "$(realpath "$3")" "./result_$(basename "$1").log";
 cat "./result_$(basename "$1").log" | \
# преобразуем список кадров в интервалы для последующей обрезки
       ./intervals2list.sh | \
       ./trim2parts_by_intervals.sh "$1" "$3" "$4";
}
function concatenateGoodParts {
  # данная функция соединяет все фрагменты в 1 файл
  # $1 - путь к временной папке для хранения фрагментов
  # $2 - путь к результирующему видеофайлу
  # $3 - битрейт видео

  (for FILE in $(ls -1 "$(realpath "$tempDir")" | sort -n -t _ -k 2) ; do echo "file '$(realpath "$tempDir")/$FILE'"; done) >list.txt ;
  ffmpeg -f concat -safe 0 -i list.txt -b:v "$3" "$2"
  rm -f list.txt;
}

# check requirements
if ! command -v awk &> /dev/null
then
    echo "awk could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v basename &> /dev/null
then
    echo "basename could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v bc &> /dev/null
then
    echo "bc could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v ffmpeg &> /dev/null
then
    echo "ffmpeg could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v grep &> /dev/null
then
    echo "grep could not be found"
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
if ! command -v rm &> /dev/null
then
    echo "rm could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v sort &> /dev/null
then
    echo "sort could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v tr &> /dev/null
then
    echo "tr could not be found"
    echo "You must install it before run this script."
    exit 1
fi

#source="./source";
#dest="./dest";
#trashPic="./trash_pic/image1.jpg";
source="./source";
dest="./dest";
trashDir=$1;
tempDir="./temp";
videoRate="2560k";
for FILE in $(ls -1 "$(realpath "$source")" | sort -n -t _ -k 2) ; do
  filename="$(realpath "$source")/$FILE";
  destFilename="$(realpath "$dest")/$FILE";
  echo "Cleaning $filename";
  makeGoodParts "$filename" "$trashDir" "$tempDir" "$videoRate";
  echo "Split $filename into parts has finished.";
  concatenateGoodParts "$tempDir" "$destFilename" "$videoRate";
  echo "Successfully filtered $filename into $destFilename";
  echo;
  clearDir "$tempDir";
done
echo "Start final converting to mp4 format.";
./convert_any2mp4.sh "$videoRate";
echo "All done!";
echo;

