#!/bin/bash

function printInterval {
  echo "frame_start $1 frame_end $2 t_start $3 t_end $4";
}
# инициализация переменных
startIsSet=false;
currentFrame=0;
previousFrame=0;
frame_start=0;
frame_end=0;
currentTime=0.000000;
previousTime=0.000000;
t_start=0.000000;
t_end=0.000000;

# чтение идет построчно
while read -r line; do
# преобразуем строку в массив слов
  read -ra lineValues <<< "$line";
  currentFrame=${lineValues[1]};
  currentTime=${lineValues[5]};
  if [ "$startIsSet" = false ]; then
    startIsSet=true;
    frame_start=${currentFrame};
    t_start=${currentTime};
  # elif [ "$(echo "diff_time=$currentTime - $previousTime;diff_time>5.0;" | bc)" -eq 1 ]; then
  elif [ "$(echo "diff_frame=$currentFrame - $previousFrame;diff_frame>1;" | bc)" -eq 1 ]; then
# конец интервала
    frame_end=${previousFrame};
    t_end=${previousTime};
    printInterval "$frame_start" "$frame_end" "$t_start" "$t_end";
    frame_start=${currentFrame};
    t_start=${currentTime};
  fi
  previousFrame=${currentFrame};
  previousTime=${currentTime};
done
# записываем последний интервал
if [ "$startIsSet" = true ]; then
  frame_end=${previousFrame};
  t_end=${previousTime};
  printInterval "$frame_start" "$frame_end" "$t_start" "$t_end";
fi



