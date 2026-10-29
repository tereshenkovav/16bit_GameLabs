Проект сделан для изучения синхронизации вывода с VGA и создания буфера в дальней памяти с последующим его обработкой/копированием средствами библиотеки C.
Движение спрайта по экрану, загруженного с файла в режиме 13h

Собирается строго для OpenWatcom
Использует нестандартные функции _fmalloc, _fmemset, _fmemcpy, _ffree

**Руководство по сборке на OpenWatcom исходников для DOS с использованием WSL**

Загружаем Apline x64 последний minirootfs

```
wget https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-minirootfs-3.24.3-x86_64.tar.gz
```

Далее устанавливаем его

```
wsl --import Alpine "%USERPROFILE%\Alpine" alpine-minirootfs-3.24.3-x86_64.tar.gz
```

и запускаем Alpine

```
wsl -d Alpine
```
внутри переходим в каталог root, создаем каталог watcom, загружаем последний
OpenWatcom портативную версию и распаковываем

```
cd ~
mkdir watcom
cd watcom
wget http://openwatcom.org/ftp/source/ow_portable_v2_stable.zip
unzip ow_portable_v2_stable.zip
```

теперь в любом каталоге можно вызывать сборку, установив переменные окружения скриптом

```
export PATH=~/watcom/binl:$PATH
export INCLUDE=~/watcom/h:$INCLUDE
export WATCOM=~/watcom
wcl prog.c
```

**Важно!** строки в файле сборки должны заканчиваться только символом 0x0A,
потому что wcl воспринимает символ 0x0D как часть команды. Иными словами,
использовать перевод строки в стиле Unix.

Пример файла находится в `build.sh`
