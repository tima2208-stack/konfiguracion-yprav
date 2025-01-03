Вот подробный список команд и пошаговое руководство для установки Alpine Linux с использованием QEMU, а также эмуляция результата (скриншот с `motd` я смогу описать, но потребуется ваш ввод данных):

### 1. **Скачайте ISO-образ Alpine Linux**
Перейдите на официальный сайт и загрузите ISO-образ:

```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.0-x86_64.iso
```

### 2. **Создайте образ жесткого диска (qcow2)**
Создайте жесткий диск объемом 500 МБ:

```bash
qemu-img create -f qcow2 alpine_disk.qcow2 500M
```

### 3. **Запустите QEMU и загрузите Alpine Linux с CD-ROM**
Запустите виртуальную машину с ISO-образом Alpine:

```bash
qemu-system-x86_64 -m 512 -cdrom alpine-standard-3.18.0-x86_64.iso -boot d -hda alpine_disk.qcow2 -net nic -net user
```

### 4. **Установите Alpine Linux на диск `sda`**
В виртуальной машине выполните следующие шаги:

1. Войдите под root:
   ```bash
   login: root
   ```
2. Запустите скрипт установки:
   ```bash
   setup-alpine
   ```
3. Следуйте инструкциям:
   - Выберите клавиатуру (например, `us`).
   - Настройте сетевые параметры, оставьте по умолчанию.
   - Установите часовой пояс (например, `UTC`).
   - Выберите зеркало пакетов.
   - Настройте пароль root.
   - В разделе `Disk to use` выберите `sda` (образ, созданный ранее).
   - Выберите опцию `sys` для установки на диск.

4. После завершения установки завершите сеанс:
   ```bash
   poweroff
   ```

### 5. **Перезапустите QEMU с загрузкой с диска `sda`**
Запустите машину, загрузив её с установленного жесткого диска:

```bash
qemu-system-x86_64 -m 512 -hda alpine_disk.qcow2 -net nic -net user
```

### 6. **Измените файл `motd`**
Войдите в систему и выполните команду для изменения `motd`:

```bash
echo "Добро пожаловать! Имя: Иван Иванов" > /etc/motd
```

### 7. **Сделайте скриншот терминала**
QEMU поддерживает создание скриншотов:

```bash
screendump screenshot.ppm
convert screenshot.ppm screenshot.png
```

Если `convert` недоступен, просто сохраните файл в формате `.ppm`.

<img width="439" alt="Снимок экрана 2024-11-27 в 06 48 11" src="https://github.com/user-attachments/assets/539644f9-c2de-466d-aaf7-4c22348d7101">
