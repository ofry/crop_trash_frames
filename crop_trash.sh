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
# $2 - путь к "плохому" кадру
# $3 - путь к временной папке для хранения фрагментов

# строится список кадров и указывается процент совпадения с "плохим" кадром
  ffmpeg -nostdin -an -i "$1" -loop 1 -i "$2" \
      -filter_complex "blend=difference:shortest=1,blackframe=0" -f null - 2>&1 | \
# выбираем только нужные строки
       grep '^\[Parsed_blackframe_1' | \
# избавляемся от лишних данных
       awk '{print $4, $5, $6, $7, $9}' | \
       tr ':' ' ' | \
# выбираем только "хорошие" кадры (степень совпадения с "плохим" кадром меньше 80%)
       awk '{if ($4 < 80) {print $1, $2, $5, $6, $7, $8, $9, $10}}' | \
# преобразуем список кадров в интервалы для последующей обрезки
       ./intervals2list.sh | \
       ./trim2parts_by_intervals.sh "$1" "$3";
}
function concatenateGoodParts {
  # данная функция соединяет все фрагменты в 1 файл
  # $1 - путь к временной папке для хранения фрагментов
  # $2 - путь к результирующему видеофайлу
  (for FILE in $(ls -1 "$(realpath "$tempDir")" | sort -n -t _ -k 2) ; do echo "file '$(realpath "$tempDir")/$FILE'"; done) >list.txt ;
  ffmpeg -f concat -safe 0 -i list.txt "$2"
  rm -f list.txt;
}

#source="./source";
#dest="./dest";
#trashPic="./trash_pic/image1.jpg";
source="./source";
dest="./dest";
trashPic=$1;
tempDir="./temp";
for FILE in $(ls -1 "$(realpath "$source")" | sort -n -t _ -k 2) ; do
  filename="$(realpath "$source")/$FILE";
  destFilename="$(realpath "$dest")/$FILE";
  echo "Cleaning $filename";
  makeGoodParts "$filename" "$trashPic" "$tempDir";
  echo "Split $filename into parts has finished.";
  concatenateGoodParts "$tempDir" "$destFilename";
  echo "Successfully filtered $filename into $destFilename";
  echo;
  clearDir "$tempDir";
done
echo "All done!"
echo;

