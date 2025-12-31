# Conky AF-Magic Theme

Минималистичная тема Conky в стиле **af-magic** (фиолетовый/серый).

![Preview](preview.png)

## Особенности

- Две панели: левая и правая (центр свободен для работы)
- Цветовая схема af-magic (purple/gray)
- Поддержка Wayland и X11
- Погода через wttr.in
- Nerd Font иконки

## Содержимое панелей

**Левая панель:**
- Часы и дата
- Система (OS, kernel, uptime, packages, DE)
- CPU с графиком
- RAM
- Диски (/, /home)
- Сеть с графиками

**Правая панель:**
- Погода
- Батарея
- Топ процессов (CPU)
- Топ процессов (RAM)
- Температура CPU
- GPU
- ASCII лого Arch

## Установка

### Быстрая установка

```bash
git clone https://github.com/judas-priest/conky-af-magic.git
cd conky-af-magic
./install.sh
```

### Ручная установка

```bash
# Зависимости
sudo pacman -S conky curl

# Опционально: шрифт
yay -S nerd-fonts-terminus

# Копирование
mkdir -p ~/.config/conky/scripts
cp left.conf right.conf ~/.config/conky/
cp scripts/weather.sh ~/.config/conky/scripts/
chmod +x ~/.config/conky/scripts/weather.sh

# Запуск
conky -c ~/.config/conky/left.conf &
conky -c ~/.config/conky/right.conf &
```

## Настройка

### Город для погоды

Отредактируй `~/.config/conky/scripts/weather.sh`:
```bash
CITY="Moscow"  # Измени на свой город
```

Или установи переменную окружения:
```bash
export CONKY_CITY="Saint Petersburg"
```

### X11 вместо Wayland

В `left.conf` и `right.conf` измени:
```lua
out_to_x = true,
out_to_wayland = false,
```

### Цвета

```lua
color0 = 'af5fff',  -- фиолетовый (основной акцент)
color1 = '8700ff',  -- тёмный фиолетовый
color2 = '5fd787',  -- зелёный/мятный
color3 = 'ffaf00',  -- оранжевый
color4 = '5fafff',  -- голубой
color5 = '3a3a3a',  -- тёмно-серый
color6 = '8a8a8a',  -- средний серый
```

### Шрифт

По умолчанию используется `Terminess Nerd Font Mono`. Если не установлен:

```bash
# Arch Linux (AUR)
yay -S nerd-fonts-terminus

# Или любой Nerd Font
sudo pacman -S ttf-jetbrains-mono-nerd
# И измени в конфигах: font = 'JetBrainsMono Nerd Font:size=11'
```

## Автозапуск

### KDE Plasma

1. System Settings → Startup and Shutdown → Autostart
2. Add Script → выбери `~/.config/conky/start.sh`

### Systemd (user)

```bash
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/conky.service << EOF
[Unit]
Description=Conky
After=graphical-session.target

[Service]
ExecStart=%h/.config/conky/start.sh
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user enable conky
systemctl --user start conky
```

## Troubleshooting

**Conky не отображается на Wayland:**
- Убедись что `out_to_wayland = true`
- Некоторые композиторы требуют `own_window_type = 'dock'`

**Температуры не работают:**
- Проверь доступные сенсоры: `sensors`
- Найди правильный hwmon: `ls /sys/class/hwmon/`
- Измени `hwmon 1 temp 1` на нужный номер

**Сеть не показывает данные:**
- Замени `wlan0` на свой интерфейс: `ip link show`

## Лицензия

MIT
