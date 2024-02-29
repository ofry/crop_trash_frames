#!/bin/bash
# данный скрипт выводит список "общих" "хороших" фреймов
# (т.е. совпадающие строки во всех файлах)

function clearDir {
  # $1 - путь к очищаемой папке
  # сохраняем только скрытые файлы

  for FILE in "$(realpath "$1")"/* ; do
    rm -rf "$FILE";
  done
}


# check requirements
if ! command -v cat &> /dev/null
then
    echo "cat could not be found"
    echo "You must install it before run this script."
    exit 1
fi
if ! command -v cp &> /dev/null
then
    echo "cp could not be found"
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
if ! command -v mv &> /dev/null
then
    echo "mv could not be found"
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

# инициализация переменных
tempDir="$1";
resultIsSet=false;
result="$2";
tempResult="./temp_result.log";

for FILE in $(ls -1 "$(realpath "$tempDir")" | sort -n -t _ -k 2) ; do
  filepath="$(realpath "$tempDir")/$FILE";
  if [ "$resultIsSet" = false ]; then
    # первый проход
    echo "Copying " "$filepath" to "$result";
    cp -f "$filepath" "$result";
    resultIsSet=true;
  fi
  echo "Processing " "$filepath";
  grep -Fof "$result" "$filepath" >"$tempResult" 2>/dev/null;
  rm -f "$result";
  mv -f "$tempResult" "$result";
  rm -f "$tempResult";
done

clearDir "$tempDir";