#!/bin/bash
# Test script to preview all weather icons with colors

# ANSI colors matching conky theme
COLOR0='\033[38;5;135m'  # af5fff - purple
COLOR3='\033[38;5;214m'  # ffaf00 - yellow/orange
COLOR4='\033[38;5;75m'   # 5fafff - blue
COLOR6='\033[38;5;245m'  # 8a8a8a - gray
NC='\033[0m'             # reset

# Nerd Font icons
NF_SUNNY=$(printf '\xf3\xb0\x96\x99')
NF_PCLOUDY=$(printf '\xf3\xb0\x96\x95')
NF_CLOUDY=$(printf '\xf3\xb0\x96\x90')
NF_RAINY=$(printf '\xf3\xb0\x96\x97')
NF_THUNDER=$(printf '\xf3\xb0\x96\x93')
NF_SNOWY="❄︎"
NF_FOG=$(printf '\xf3\xb0\x96\x91')
NF_NIGHT=$(printf '\xf3\xb0\x96\x94')

echo ""
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo -e "${COLOR0}  WEATHER ICONS TEST${NC}"
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo ""

echo -e "${COLOR3}${NF_SUNNY}${NC}  Солнечно         (color3 жёлтый)"
echo -e "${COLOR3}${NF_PCLOUDY}${NC}  Переменная обл.  (color3 жёлтый)"
echo -e "${COLOR6}${NF_CLOUDY}${NC}  Облачно          (color6 серый)"
echo -e "${COLOR4}${NF_RAINY}${NC}  Дождь            (color4 синий)"
echo -e "${COLOR3}${NF_THUNDER}${NC}  Гроза            (color3 жёлтый)"
echo -e "${COLOR4}${NF_SNOWY}${NC}  Снег             (color4 синий)"
echo -e "${COLOR6}${NF_FOG}${NC}  Туман            (color6 серый)"
echo -e "${COLOR3}${NF_NIGHT}${NC}  Ночь             (color3 жёлтый)"

echo ""
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo -e "${COLOR0}  WIND ARROWS${NC}"
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo ""

echo -e "${COLOR4}↓${NC}  Север   (color4 синий - холодный)"
echo -e "${COLOR3}↑${NC}  Юг      (color3 оранжевый - тёплый)"
echo -e "${COLOR6}←${NC}  Восток  (color6 серый)"
echo -e "${COLOR6}→${NC}  Запад   (color6 серый)"
echo -e "${COLOR4}↘${NC}  СВ      (color4 синий)"
echo -e "${COLOR4}↙${NC}  СЗ      (color4 синий)"
echo -e "${COLOR3}↗${NC}  ЮВ      (color3 оранжевый)"
echo -e "${COLOR3}↖${NC}  ЮЗ      (color3 оранжевый)"

echo ""
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo -e "${COLOR0}  MOON${NC}"
echo -e "${COLOR0}═══════════════════════════════════════${NC}"
echo ""

echo -e "${COLOR3}${NF_NIGHT}${NC}  Луна (color3 жёлтый)"

echo ""
