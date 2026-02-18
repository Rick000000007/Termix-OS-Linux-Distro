#!/data/data/com.termux/files/usr/bin/bash
set -e

clear
echo "======================================"
echo "   Termix OS - Linux Distro v1.0.1"
echo "   Installer by ravlav"
echo "======================================"
echo ""

step() {
  echo ""
  echo "[$1] $2"
  echo "--------------------------------------"
}

# ---------------------------
# 1) Update Termux (SAFE)
# ---------------------------
step "1/7" "Updating Termux (safe mode)"
pkg update -y

echo "Note: Full upgrade is skipped for stability."
echo "You can run later: pkg upgrade -y"

# ---------------------------
# 2) Install basic tools
# ---------------------------
step "2/7" "Installing basic tools"
pkg install -y git curl wget nano unzip zip tar

# ---------------------------
# 3) Dev tools
# ---------------------------
step "3/7" "Installing Dev tools"
pkg install -y python nodejs openjdk-17

# ---------------------------
# 4) Proot + proot-distro
# ---------------------------
step "4/7" "Installing proot + proot-distro"
pkg install -y proot proot-distro

# ---------------------------
# 5) Shell Enhancements (FORCE ZSH)
# ---------------------------
step "5/7" "Installing Zsh + Starship + Forcing Zsh"
pkg install -y zsh starship

mkdir -p ~/.config
if [ -f "$HOME/Termix-OS-Linux-Distro/config/starship.toml" ]; then
  cp "$HOME/Termix-OS-Linux-Distro/config/starship.toml" ~/.config/starship.toml
fi

# Create clean zshrc (prevents prompt bugs)
cat > ~/.zshrc <<'EOF'
# Termix OS - Zsh config
export PATH="$HOME/bin:$PATH"

# Starship prompt
eval "$(starship init zsh)"

# Useful aliases
alias ll="ls -la"
alias cls="clear"
EOF

# Force ZSH now
chsh -s zsh || true

echo ""
echo "Zsh is now set as default shell."
echo "Restart Termux after install to fully apply it."

# ---------------------------
# 6) Install Termix Store
# ---------------------------
step "6/7" "Installing Termix Store"
bash "$HOME/Termix-OS-Linux-Distro/termix-store.sh"

# ---------------------------
# 7) Install Termux-X11 + XFCE
# ---------------------------
step "7/7" "Installing Termux-X11 + XFCE Desktop"
pkg install -y x11-repo || true
pkg update -y

pkg install -y termux-x11-nightly xfce4 xfce4-session xfce4-terminal thunar

# ---------------------------
# Create shortcuts
# ---------------------------
step "FINAL" "Creating shortcuts"
mkdir -p ~/bin

cat > ~/bin/termix-xfce <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e
export DISPLAY=:1

termux-x11 :1 &
sleep 2
startxfce4
EOF

chmod +x ~/bin/termix-xfce

# ---------------------------
# Done
# ---------------------------
echo ""
echo "======================================"
echo "DONE ✅ Termix OS Installed!"
echo "======================================"
echo ""
echo "Run Store : termix-store"
echo "Run XFCE  : termix-xfce"
echo ""
echo "IMPORTANT: Restart Termux now."
echo ""
