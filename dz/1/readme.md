import sys
import os
import tarfile
from PyQt5.QtWidgets import QApplication, QMainWindow, QTextEdit, QLineEdit, QVBoxLayout, QWidget

class VirtualFileSystem:
    def __init__(self, tar_path):
        self.current_dir = "/"
        self.fs_root = "/tmp/vfs"
        self.extract_tar(tar_path)

    def extract_tar(self, tar_path):
        with tarfile.open(tar_path, 'r') as tar:
            tar.extractall(self.fs_root)

    def list_dir(self):
        return os.listdir(os.path.join(self.fs_root, self.current_dir.strip('/')))

    def change_dir(self, path):
        new_path = os.path.join(self.fs_root, path.strip('/'))
        if os.path.isdir(new_path):
            self.current_dir = '/' + os.path.relpath(new_path, self.fs_root)
            return f"Changed directory to {self.current_dir}"
        return f"Error: {path} is not a directory"

    def current_path(self):
        return self.current_dir

class CommandHandler:
    def __init__(self, vfs):
        self.vfs = vfs

    def execute(self, command):
        parts = command.split()
        cmd = parts[0]

        if cmd == "ls":
            return "\n".join(self.vfs.list_dir())
        elif cmd == "cd":
            return self.vfs.change_dir(parts[1] if len(parts) > 1 else "/")
        elif cmd == "uname":
            return "UNIX Shell Emulator"
        elif cmd == "whoami":
            return "shell-user"
        elif cmd == "pwd":
            return self.vfs.current_path()
        else:
            return f"Unknown command: {cmd}"

class Emulator(QMainWindow):
    def __init__(self, username, vfs_path, startup_script):
        super().__init__()
        self.username = username
        self.vfs = VirtualFileSystem(vfs_path)
        self.command_handler = CommandHandler(self.vfs)

        # UI setup
        self.setWindowTitle("Shell Emulator")
        self.setGeometry(100, 100, 800, 600)

        self.text_area = QTextEdit(self)
        self.text_area.setReadOnly(True)

        self.command_input = QLineEdit(self)
        self.command_input.returnPressed.connect(self.handle_command)

        layout = QVBoxLayout()
        layout.addWidget(self.text_area)
        layout.addWidget(self.command_input)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        # Приветственное сообщение
        self.text_area.append(f"Добро пожаловать, {self.username}!")
        self.text_area.append(f"Текущая директория: {self.vfs.current_path()}")
        self.text_area.append("Введите команду или 'exit' для выхода.")

        # Run startup script
        self.run_startup_script(startup_script)

    def run_startup_script(self, script_path):
        if os.path.exists(script_path):
            with open(script_path, 'r') as script:
                for line in script:
                    self.execute_command(line.strip())

    def handle_command(self):
        command = self.command_input.text()
        self.command_input.clear()
        self.execute_command(command)

    def execute_command(self, command):
        if command.lower() == "exit":
            self.close()
        else:
            result = self.command_handler.execute(command)
            self.text_area.append(f"{self.username}@emulator:{self.vfs.current_path()}$ {command}")
            self.text_area.append(result)
            self.text_area.append(f"\nТекущая директория: {self.vfs.current_path()}")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Shell Emulator")
    parser.add_argument("vfs", help="Path to the virtual file system archive")
    parser.add_argument("--username", default="tmironov", help="Username for the shell prompt")
    parser.add_argument("--script", default="startup.sh", help="Path to the startup script")
    args = parser.parse_args()

    app = QApplication(sys.argv)
    emulator = Emulator(args.username, args.vfs, args.script)
    emulator.show()
    sys.exit(app.exec_())




тесты 
import unittest
import os
import tarfile
import tempfile
from unittest.mock import MagicMock
from emulator import VirtualFileSystem, CommandHandler, Emulator

class TestVirtualFileSystem(unittest.TestCase):
    def setUp(self):
        # Создаем временную директорию и tar-файл
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_tar = os.path.join(self.temp_dir.name, "test_vfs.tar")

        # Создаем временные файлы и папки для архива
        test_file_path = os.path.join(self.temp_dir.name, "test_file.txt")
        test_dir_path = os.path.join(self.temp_dir.name, "test_dir")
        os.mkdir(test_dir_path)
        with open(test_file_path, "w") as f:
            f.write("Test content")

        # Создаем tar-архив
        with tarfile.open(self.test_tar, "w") as tar:
            tar.add(test_file_path, arcname="test_file.txt")
            tar.add(test_dir_path, arcname="test_dir")

        self.vfs = VirtualFileSystem(self.test_tar)

    def tearDown(self):
        # Удаляем временные файлы и директории
        self.temp_dir.cleanup()

    def test_list_dir(self):
        self.assertIn("test_file.txt", self.vfs.list_dir())
        self.assertIn("test_dir", self.vfs.list_dir())

    def test_change_dir(self):
        self.assertEqual(self.vfs.change_dir("test_dir"), "Changed directory to /test_dir")
        self.assertEqual(self.vfs.current_path(), "/test_dir")

    def test_current_path(self):
        self.assertEqual(self.vfs.current_path(), "/")


class TestCommandHandler(unittest.TestCase):
    def setUp(self):
        # Создаем VFS для тестов
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_tar = os.path.join(self.temp_dir.name, "test_vfs.tar")

        test_file_path = os.path.join(self.temp_dir.name, "test_file.txt")
        os.mkdir(os.path.join(self.temp_dir.name, "test_dir"))
        with open(test_file_path, "w") as f:
            f.write("Test content")

        with tarfile.open(self.test_tar, "w") as tar:
            tar.add(test_file_path, arcname="test_file.txt")
            tar.add(os.path.join(self.temp_dir.name, "test_dir"), arcname="test_dir")

        self.vfs = VirtualFileSystem(self.test_tar)
        self.ch = CommandHandler(self.vfs)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_ls(self):
        result = self.ch.execute("ls")
        self.assertIn("test_file.txt", result)
        self.assertIn("test_dir", result)

    def test_cd(self):
        self.ch.execute("cd test_dir")
        self.assertEqual(self.vfs.current_path(), "/test_dir")

    def test_pwd(self):
        self.assertEqual(self.ch.execute("pwd"), "/")

    def test_uname(self):
        self.assertEqual(self.ch.execute("uname"), "UNIX Shell Emulator")

    def test_whoami(self):
        self.assertEqual(self.ch.execute("whoami"), "shell-user")

    def test_unknown_command(self):
        self.assertEqual(self.ch.execute("unknown"), "Unknown command: unknown")


class TestEmulator(unittest.TestCase):
    def setUp(self):
   
        self.emulator = Emulator("test_user", "test_vfs.tar", "test_script.sh")
        self.emulator.text_area = MagicMock()

    def test_initialization(self):
        self.assertEqual(self.emulator.username, "test_user")
        self.assertIsInstance(self.emulator.vfs, VirtualFileSystem)
        self.assertIsInstance(self.emulator.command_handler, CommandHandler)

    def test_execute_command(self):
       
        self.emulator.command_handler.execute = MagicMock(return_value="mocked_ls_output")
        self.emulator.execute_command("ls")
        # Проверяем, что результат команды был выведен в текстовую область
        self.emulator.text_area.append.assert_any_call("test_user@emulator:/$ ls")
        self.emulator.text_area.append.assert_any_call("mocked_ls_output")

    def test_exit_command(self):
     
        self.emulator.close = MagicMock()
        self.emulator.execute_command("exit")
        # Проверяем, что метод close() был вызван
        self.emulator.close.assert_called_once()


if __name__ == '__main__':
    unittest.main()
<img width="1440" alt="Снимок экрана 2024-12-26 в 19 14 08" src="https://github.com/user-attachments/assets/49b96859-25a3-4625-ad2f-21bc93cf7631" />
