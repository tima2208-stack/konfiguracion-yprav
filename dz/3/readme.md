project/
│
├── config_parser.py         # Основной код
├── test_config_parser.py    # Тесты для config_parser.py
├── input.txt                # Пример входного файла
└── output.yaml              # Пример выходного файла

import re
import yaml
import sys

class ConfigParser:
    def __init__(self):
        self.constants = {}
        self.output = {}

    def remove_comments(self, text):
        # Удаление однострочных комментариев
        text = re.sub(r"с.*?$", "", text, flags=re.MULTILINE)
        # Удаление многострочных комментариев
        text = re.sub(r"#\|.*?\|#", "", text, flags=re.DOTALL)
        return text

    def parse_constant(self, line):
        match = re.match(r"(\w+)\s*=\s*(.*);", line)
        if match:
            name, value = match.groups()
            value = self.evaluate_value(value.strip())
            self.constants[name] = value
        else:
            raise SyntaxError(f"Invalid constant declaration: {line}")

    def evaluate_value(self, value):
        # Проверка на числовое значение
        if value.isdigit():
            return int(value)
        # Проверка на массив
        elif re.match(r"\(\s*(.*)\s*\)", value):
            items = re.findall(r"\w+", value)
            return items
        # Проверка на строку константы
        elif value in self.constants:
            return self.constants[value]
        else:
            return value

    def parse_line(self, line):
        line = line.strip()
        if not line:
            return

        # Обработка объявления констант
        if "=" in line:
            self.parse_constant(line)
        # Обработка вычисления констант
        elif re.match(r"\{\w+\}", line):
            const_name = line.strip("{}")
            if const_name in self.constants:
                self.output[const_name] = self.constants[const_name]
            else:
                raise ValueError(f"Undefined constant: {const_name}")
        else:
            raise SyntaxError(f"Unknown syntax: {line}")

    def parse(self, input_text):
        cleaned_text = self.remove_comments(input_text)
        for line in cleaned_text.splitlines():
            self.parse_line(line)

    def to_yaml(self, output_path):
        with open(output_path, "w", encoding="utf-8") as yaml_file:
            yaml.dump(self.output, yaml_file, allow_unicode=True)
        print(f"YAML файл успешно создан: {output_path}")

# Основная функция
def main(input_path, output_path):
    try:
        with open(input_path, "r", encoding="utf-8") as file:
            input_text = file.read()

        parser = ConfigParser()
        parser.parse(input_text)
        parser.to_yaml(output_path)

    except Exception as e:
        print(f"Ошибка: {e}")

if __name__ == "__main__":
    # Пример использования: python script.py input.txt output.yaml
    if len(sys.argv) != 3:
        print("Использование: python script.py <входной_файл> <выходной_файл>")
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2]
        main(input_path, output_path)

      
        
        
        

тесты

        import unittest
from config_parser import ConfigParser
from unittest.mock import mock_open, patch
import yaml

class TestConfigParser(unittest.TestCase):

    def setUp(self):
        self.parser = ConfigParser()

    def test_remove_comments(self):
        input_text = """
        const1 = 10; с комментарий
        #| многострочный
        комментарий |#
        const2 = (a, b, c);
        """
        expected = "const1 = 10;\n\nconst2 = (a, b, c);"
        result = self.parser.remove_comments(input_text)
        self.assertEqual(result.strip(), expected.strip())

    def test_parse_constant_integer(self):
        self.parser.parse_constant("const1 = 42;")
        self.assertEqual(self.parser.constants["const1"], 42)

    def test_parse_constant_array(self):
        self.parser.parse_constant("const2 = (a, b, c);")
        self.assertEqual(self.parser.constants["const2"], ["a", "b", "c"])

    def test_parse_constant_reference(self):
        self.parser.parse_constant("const1 = 42;")
        self.parser.parse_constant("const2 = const1;")
        self.assertEqual(self.parser.constants["const2"], 42)

    def test_parse_line_valid(self):
        self.parser.parse_line("const1 = 10;")
        self.assertEqual(self.parser.constants["const1"], 10)

    def test_parse_line_invalid(self):
        with self.assertRaises(SyntaxError):
            self.parser.parse_line("invalid_line")

    def test_to_yaml(self):
        self.parser.constants = {"key": "value"}
        mock_output_path = "output.yaml"
        with patch("builtins.open", mock_open()) as mock_file:
            self.parser.to_yaml(mock_output_path)
            mock_file.assert_called_with(mock_output_path, "w", encoding="utf-8")

    def test_parse_with_full_input(self):
        input_text = """
        const1 = 42; с комментарий
        const2 = (a, b, c);
        {const1}
        """
        self.parser.parse(input_text)
        self.assertEqual(self.parser.output["const1"], 42)

if __name__ == "__main__":
    unittest.main()
