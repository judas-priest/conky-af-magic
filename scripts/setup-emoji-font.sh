#!/bin/bash
#
# Setup emoji font for Conky weather icons
#

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${PURPLE}Setting up emoji font support...${NC}"

# Check if Noto Color Emoji is installed
if ! fc-list | grep -qi "noto color emoji"; then
    echo -e "${YELLOW}Noto Color Emoji not found.${NC}"
    echo -e "Install with: ${GRAY}sudo pacman -S noto-fonts-emoji${NC}"
    echo ""
    read -p "Install now? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo pacman -S --noconfirm noto-fonts-emoji
    fi
fi

# Create fontconfig
FONTCONFIG_DIR="$HOME/.config/fontconfig"
FONTCONFIG_FILE="$FONTCONFIG_DIR/fonts.conf"

mkdir -p "$FONTCONFIG_DIR"

if [[ -f "$FONTCONFIG_FILE" ]]; then
    echo -e "${YELLOW}fonts.conf already exists${NC}"
    if grep -q "Noto Color Emoji" "$FONTCONFIG_FILE"; then
        echo -e "${GREEN}Emoji font already configured!${NC}"
        exit 0
    fi
    echo -e "${GRAY}Backing up to fonts.conf.bak${NC}"
    cp "$FONTCONFIG_FILE" "$FONTCONFIG_FILE.bak"
fi

cat > "$FONTCONFIG_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo -e "${GREEN}Created $FONTCONFIG_FILE${NC}"

# Refresh font cache
echo -e "${GRAY}Refreshing font cache...${NC}"
fc-cache -f

echo ""
echo -e "${GREEN}Done! Restart Conky to see weather emojis.${NC}"
