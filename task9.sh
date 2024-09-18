#!/bin/bash

# Проверяем количество аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <входной файл> <выходной файл>"
    exit 1
fi

input_file="$1"
output_file="$2"

# Используем sed для замены 4 пробелов на табуляцию
sed 's/    /\t/g' "$input_file" > "$output_file"

echo "Замена завершена. Результат записан в '$output_file'."
