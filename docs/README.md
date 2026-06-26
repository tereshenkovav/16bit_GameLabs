# Несортированный сборник заметок по изучению 16-битной разработки

## Команды битового сдвига с константой требуют процессора 386 или выше

Найдены проблемные строки — команды битового сдвига в генераторе случайных
чисел не соответствуют процессору. Некорректно:
```
shl ax,7
```
Корректно:
```
mov cl,7
shl ax,cl
```

## Подключение OBJ от Digital Mars Compiler к QuickBasic

Нужно обязательно создать файлы lib и qlb

```
link /q lib16bit.obj, lib16bit.qlb, NUL, bqlb45.lib
del lib16bit.lib
lib lib16bit.lib+lib16bit.obj,NUL
```
и запускать потом среду как `qb /l lib16bit.qlb`

Также функции должны иметь явное указание типа через символ:

```
DECLARE FUNCTION getTimer% CDECL()
```
В остальном, всё как у PowerBasic

## Более аккуратная сборка библиотеки на OpenWatcom для подключения к QuickBasic

Пример кода:
```
int funcAB(int a, int b) {
  return a+b ;
}
```
пример сборки (ключ ecc задает cdecl, mm - модель памяти medium, s - отключает проверку переполнения стека)
```
wcc -ecc -mm -s mylib.c
del mylib.lib
wlib mylib.lib mylib.obj
```
пример подключения
```
DECLARE FUNCTION funcAB% CDECL (BYVAL a AS INTEGER, BYVAL b AS INTEGER)
```
