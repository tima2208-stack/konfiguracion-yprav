<img width="1440" alt="Снимок экрана 2024-12-26 в 19 20 56" src="https://github.com/user-attachments/assets/6647b805-1580-457e-80e3-91a835390969" />






import os
import subprocess
from pathlib import Path

def get_git_dependencies(repo_path, branch_name):
    """
    Получает список коммитов и файлов из указанной ветки git-репозитория.
    """
    os.chdir(repo_path)
    try:
        # Получаем коммиты и их файлы
        result = subprocess.run(
            ["git", "log", branch_name, "--name-only", "--pretty=format:%H"],
            capture_output=True, text=True
        )
        return result.stdout
    except Exception as e:
        print(f"Ошибка при работе с git: {e}")
        return ""

def parse_dependencies(git_log):
    """
    Парсит git логи для создания зависимостей в формате словаря.
    """
    dependencies = {}
    current_commit = None

    for line in git_log.split("\n"):
        if line.strip():  # Пропускаем пустые строки
            if len(line.strip()) == 40:  # Если строка выглядит как SHA1 коммита
                current_commit = line.strip()
                dependencies[current_commit] = []
            elif current_commit:  # Если строка — имя файла
                dependencies[current_commit].append(line.strip())
    return dependencies


def generate_plantuml_code(dependencies):
    """
    Генерирует PlantUML код для графа зависимостей.
    """
    plantuml_code = "@startuml\n"
    plantuml_code += "title Граф зависимостей для ветки\n"

    for commit, files in dependencies.items():
        for file in set(files):  # Используем set для избежания дубликатов
            if commit != file:  # Исключаем самозависимости
                plantuml_code += f'  "{commit}" --> "{file}"\n'
    plantuml_code += "@enduml"

    return plantuml_code


def save_to_file(output_path, plantuml_code):
    """
    Сохраняет PlantUML код в файл.
    """
    with open(output_path, "w", encoding="utf-8") as file:
        file.write(plantuml_code)
    print(f"PlantUML код сохранён в: {output_path}")

def main():
    # Пути к репозиторию и файлам
    repo_path = input("Введите путь к git-репозиторию: ").strip()
    output_file = input("Введите путь для сохранения файла (например, graph.puml): ").strip()
    branch_name = input("Введите имя ветки для анализа: ").strip()

    # Проверка путей
    if not Path(repo_path).is_dir():
        print("Неверный путь к репозиторию.")
        return

    # Получение зависимостей
    git_log = get_git_dependencies(repo_path, branch_name)
    if not git_log:
        print("Не удалось получить логи git.")
        return

    dependencies = parse_dependencies(git_log)

    # Генерация и сохранение PlantUML
    plantuml_code = generate_plantuml_code(dependencies)
    save_to_file(output_file, plantuml_code)

if __name__ == "__main__":
    main()

test

import unittest
from unittest.mock import patch, mock_open
from visualizer import get_git_dependencies, parse_dependencies, generate_plantuml_code, save_to_file
import os

class TestVisualizer(unittest.TestCase):

    @patch("subprocess.run")
    def test_get_git_dependencies_success(self, mock_run):
        mock_run.return_value.stdout = "commit1\nfile1.txt\nfile2.txt\ncommit2\nfile3.txt"
        result = get_git_dependencies("/path/to/repo", "main")
        self.assertEqual(result, "commit1\nfile1.txt\nfile2.txt\ncommit2\nfile3.txt")

    @patch("subprocess.run", side_effect=FileNotFoundError)
    def test_get_git_dependencies_failure(self, mock_run):
        with self.assertRaises(RuntimeError):
            get_git_dependencies("/invalid/repo", "main")

    def test_parse_dependencies(self):
        git_log = "commit1\nfile1.txt\nfile2.txt\ncommit2\nfile3.txt"
        expected_output = {
            "commit1": ["file1.txt", "file2.txt"],
            "commit2": ["file3.txt"]
        }
        result = parse_dependencies(git_log)
        self.assertEqual(result, expected_output)

    def test_parse_dependencies_with_empty_lines(self):
        git_log = "commit1\nfile1.txt\n\ncommit2\nfile3.txt\n"
        expected_output = {
            "commit1": ["file1.txt"],
            "commit2": ["file3.txt"]
        }
        result = parse_dependencies(git_log)
        self.assertEqual(result, expected_output)

    def test_generate_plantuml_code(self):
        dependencies = {
            "commit1": ["file1.txt", "file2.txt"],
            "commit2": ["file3.txt"]
        }
        expected_output = (
            "@startuml\n"
            "title Граф зависимостей для ветки\n"
            '  "commit1" --> "file1.txt"\n'
            '  "commit1" --> "file2.txt"\n'
            '  "commit2" --> "file3.txt"\n'
            "@enduml"
        )
        result = generate_plantuml_code(dependencies)
        self.assertEqual(result.strip(), expected_output.strip())

    @patch("builtins.open", new_callable=mock_open)
    def test_save_to_file(self, mock_file):
        plantuml_code = "@startuml\nSome content\n@enduml"
        save_to_file("/path/to/output.puml", plantuml_code)
        mock_file.assert_called_with("/path/to/output.puml", "w", encoding="utf-8")
        mock_file().write.assert_called_once_with(plantuml_code)

if __name__ == "__main__":
    unittest.main()
