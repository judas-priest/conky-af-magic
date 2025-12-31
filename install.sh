#!/bin/bash
#
# Conky AF-Magic Theme Installer
# https://github.com/judas-priest/conky-af-magic
#

set -e

# Colors
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Config
REPO_URL="https://github.com/judas-priest/conky-af-magic"
CONFIG_DIR="$HOME/.config/conky"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${PURPLE}"
cat << 'EOF'
   ╔═══════════════════════════════════════════╗
   ║     CONKY AF-MAGIC THEME INSTALLER        ║
   ║        Purple/Gray Minimal Theme          ║
   ╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check dependencies
echo -e "${GRAY}[1/5]${NC} Checking dependencies..."

check_dep() {
    if command -v "$1" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "  ${RED}✗${NC} $1 ${YELLOW}(missing)${NC}"
        return 1
    fi
}

MISSING=0
check_dep "conky" || MISSING=1
check_dep "curl" || MISSING=1

# Check font
if fc-list | grep -qi "terminess"; then
    echo -e "  ${GREEN}✓${NC} Terminess Nerd Font"
else
    echo -e "  ${YELLOW}!${NC} Terminess Nerd Font ${GRAY}(optional, will use fallback)${NC}"
fi

if [[ $MISSING -eq 1 ]]; then
    echo ""
    echo -e "${YELLOW}Missing dependencies. Install with:${NC}"
    echo -e "${GRAY}  sudo pacman -S conky curl${NC}"
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Backup existing config
echo -e "${GRAY}[2/5]${NC} Backing up existing config..."
if [[ -d "$CONFIG_DIR" ]]; then
    BACKUP_DIR="$CONFIG_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo -e "  ${GREEN}✓${NC} Backed up to ${GRAY}$BACKUP_DIR${NC}"
else
    echo -e "  ${GRAY}-${NC} No existing config"
fi

# Install files
echo -e "${GRAY}[3/5]${NC} Installing theme files..."
mkdir -p "$CONFIG_DIR/scripts"

cp "$SCRIPT_DIR/left.conf" "$CONFIG_DIR/"
cp "$SCRIPT_DIR/right.conf" "$CONFIG_DIR/"
cp "$SCRIPT_DIR/scripts/weather.sh" "$CONFIG_DIR/scripts/"

chmod +x "$CONFIG_DIR/scripts/weather.sh"

echo -e "  ${GREEN}✓${NC} Files installed to ${GRAY}$CONFIG_DIR${NC}"

# Create start script
echo -e "${GRAY}[4/5]${NC} Creating start script..."

cat > "$CONFIG_DIR/start.sh" << 'STARTSCRIPT'
#!/bin/bash
# Conky AF-Magic start script

killall conky 2>/dev/null
sleep 1

conky -c ~/.config/conky/left.conf -d &
conky -c ~/.config/conky/right.conf -d &

echo "Conky started!"
STARTSCRIPT

chmod +x "$CONFIG_DIR/start.sh"
echo -e "  ${GREEN}✓${NC} Start script created"

# Configure city
echo -e "${GRAY}[5/5]${NC} Configuration..."
echo ""
read -p "Enter your city for weather (default: Moscow): " CITY
CITY="${CITY:-Moscow}"

sed -i "s/CITY=\"\${CONKY_CITY:-Moscow}\"/CITY=\"\${CONKY_CITY:-$CITY}\"/" "$CONFIG_DIR/scripts/weather.sh"
echo -e "  ${GREEN}✓${NC} City set to: ${PURPLE}$CITY${NC}"

# X11 vs Wayland
echo ""
echo -e "Display server:"
echo -e "  ${GRAY}1)${NC} Wayland (KDE Plasma 6, GNOME 40+)"
echo -e "  ${GRAY}2)${NC} X11"
read -p "Select [1/2] (default: 1): " DISPLAY_SERVER
DISPLAY_SERVER="${DISPLAY_SERVER:-1}"

if [[ "$DISPLAY_SERVER" == "2" ]]; then
    sed -i 's/out_to_wayland = true/out_to_wayland = false/' "$CONFIG_DIR/left.conf"
    sed -i 's/out_to_wayland = true/out_to_wayland = false/' "$CONFIG_DIR/right.conf"
    sed -i 's/out_to_x = false/out_to_x = true/' "$CONFIG_DIR/left.conf"
    sed -i 's/out_to_x = false/out_to_x = true/' "$CONFIG_DIR/right.conf"
    echo -e "  ${GREEN}✓${NC} Configured for X11"
else
    echo -e "  ${GREEN}✓${NC} Configured for Wayland"
fi

# Done
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "Start conky:"
echo -e "  ${PURPLE}~/.config/conky/start.sh${NC}"
echo ""
echo -e "Add to autostart (KDE):"
echo -e "  ${GRAY}System Settings → Startup → Add Script${NC}"
echo -e "  ${GRAY}Select: ~/.config/conky/start.sh${NC}"
echo ""

read -p "Start conky now? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    "$CONFIG_DIR/start.sh"
fi
