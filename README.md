# crop_trash_frames

Этот *nix-консольный скрипт удаляет "мусорные" кадры вместе с аудио из данных видеофайлов.

Получить его можно следующей командой:
```bash
git clone https://github.com/ofry/crop_trash_frames.git
cd ./crop_trash_frames
```

В папке `source` должны располагаться исходные файлы с одним и тем же набором "мусорных" кадров (которые должны быть удалены
из видео).

После выполнения скрипта отфильтрованные видео попадут
в папку `dest`.

Пример выполнения:

```bash
./crop_trash.sh "./trash_pic"
```

где `"./trash_pic"` - папка с мусорными кадрами.

Мусорный кадр (если известен его номер внутри видео) можно получить следующим образом:
```bash
 ./get_single_frame.sh "путь_к_видеофайлу" номер_кадра "куда_сохранять"
```
Например:
```bash
 ./get_single_frame.sh "./source/Test.avi" 1000 "./image1000.jpg"
```

Если известен timestamp мусорного кадра, то его можно получить так:
```bash
 ./get_single_frame_by_timestamp.sh "путь_к_видеофайлу" timestamp "куда_сохранять"
```
Например:
```bash
 ./get_single_frame_by_timestamp.sh "./source/Test.avi" 00:00:05 "./image1000.jpg"
```

Также был добавлен скрипт, конвертирующий результаты в mp4 (mpeg4 + aac).
```bash
 ./convert_any2mp4.sh
```

Зависимости (кроме стандартных консольных утилит):

```
ffmpeg
```