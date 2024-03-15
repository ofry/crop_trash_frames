#!/bin/bash
# Данный скрипт разделяет видеофайл на фрагменты
# Правила деления на фрагменты читаются из stdin
# Формат строки:
# frame_start 6 frame_end 103 t_start 0.240000 t_end 4.120000
# $1 - путь к видеофайлу
# $2 - путь к папке, куда будут записываться фрагменты
# $3 - битрейт видео


function clearDir {
  # $1 - путь к очищаемой папке
  # сохраняем только скрытые файлы

  for FILE in "$(realpath "$1")"/* ; do
    rm -rf "$FILE";
  done
}

# инициализация переменных
n=0;
# start_frame=0;
# end_frame=0;
start=0.000000;
end=0.000000;
baseName=$(basename "$1");
ext=${baseName##*.};
# очищаем мусор
clearDir "$2";
# чтение идет построчно
while read -r line; do
  # преобразуем строку в массив слов
  read -ra lineValues <<< "$line";
#  start_frame=${lineValues[1]};
#  end_frame=${lineValues[3]};
  start=${lineValues[5]};
  end=${lineValues[7]};

  # непосредственно разделение

  echo "Interval no. $((n+1)) of file $1 - from $start to $end";
  # echo -nostdin -accurate_seek -i "$1" -ss "$start" -to "$end" "$(realpath "$2")"/part_"$n"".""$ext";
  ffmpeg -nostdin -accurate_seek -i "$1" -ss "$start" -to "$end" -b:v "$3" \
     "$(realpath "$2")"/part_"$n"".""$ext"  >/dev/null 2>&1;
  echo "Processed interval no. $((n+1)) of file $1";
  ((++n));
done