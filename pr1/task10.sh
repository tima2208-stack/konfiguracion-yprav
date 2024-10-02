#!/bin/bash

# Проверяем количество аргументов
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <директория>"
    exit 1
fi

directory="$1"

# Используем find для поиска пустых текстовых файлов
find "$directory" -type f -name "*.txt" -empty -print
