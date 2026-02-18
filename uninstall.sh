cd ~/Termix-OS-Linux-Distro

cat > uninstall.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================"
echo "   Termix OS Uninstaller"
echo "======================================"
echo ""

echo "[+] Removing Termix Store..."
rm -rf ~/termix-store || true

echo "[+] Removing shortcuts..."
rm -f ~/bin/termix-store ~/bin/termix-xfce || true

echo ""
echo "DONE ✅"
echo "Note: Installed packages are not removed automatically."
echo ""
EOF

chmod +x uninstall.sh
