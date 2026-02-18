cat > install.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e

clear
echo "======================================"
echo "   Termix OS - Linux Distro"
echo "   Installer by ravlav"
echo "======================================"
echo ""

pkg update -y
pkg upgrade -y || true

pkg install -y curl wget git nano zip unzip htop termux-tools

echo ""
echo "[+] Installing Desktop (XFCE + Termux-X11)..."

pkg install -y x11-repo || true
pkg update -y

# Termux-X11 package name fix
pkg install -y termux-x11 xfce4 xfce4-session xfce4-terminal thunar dbus

echo ""
echo "[+] Installing Termix Store..."

if [ -f "$HOME/Termix-OS-Linux-Distro/termix-store.sh" ]; then
  bash "$HOME/Termix-OS-Linux-Distro/termix-store.sh"
else
  echo "[!] termix-store.sh not found in:"
  echo "    $HOME/Termix-OS-Linux-Distro/"
  echo "    Skipping store install."
fi

echo ""
echo "[+] Creating commands..."
mkdir -p ~/bin

cat > ~/bin/termix-store <<'EOT'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/termix-store
./run.sh
EOT

cat > ~/bin/termix-xfce <<'EOT'
#!/data/data/com.termux/files/usr/bin/bash
export XDG_RUNTIME_DIR=$TMPDIR
export DISPLAY=:1

# start dbus if not running
if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
  dbus-daemon --session --fork >/dev/null 2>&1 || true
fi

# start x11 server
termux-x11 :1 >/dev/null 2>&1 &
sleep 2

startxfce4
EOT

chmod +x ~/bin/termix-store ~/bin/termix-xfce

if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

echo ""
echo "======================================"
echo "DONE ✅"
echo "Run store: termix-store"
echo "Run XFCE : termix-xfce"
echo "======================================"
echo ""
EOF

chmod +x install.sh
