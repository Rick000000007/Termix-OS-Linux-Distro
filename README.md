Termix OS – Linux Distro (v1.0.0)

Termix OS is a Termux enhancement project that gives you a clean “Linux-like” experience on Android.

It includes:
- Termix Store (App-Store style GUI for Termux packages)
- XFCE Desktop (via Termux-X11)
- Simple commands: termix-store and termix-xfce
- Fully open-source under GPLv3

Disclaimer:
Not affiliated with Termux. Termux is owned by its respective developers.


==========================
INSTALLATION (RECOMMENDED)
==========================

Run this inside Termux:
```bash
pkg install -y git && cd ~ && rm -rf Termix-OS-Linux-Distro && git clone https://github.com/Rick000000007/Termix-OS-Linux-Distro.git && cd Termix-OS-Linux-Distro && bash install.sh |Bash
```
=================================
Terminal Experience (Zsh Enhanced)
=================================
Termix OS also enables:
- ✅ Zsh as default shell
- ✅ TAB Autocomplete
- ✅ Autosuggestions (ghost text while typing)
- ✅ Syntax highlighting
- ✅ Starship prompt theme

==========================
ALTERNATIVE INSTALL (MANUAL)
==========================

pkg update -y
pkg install -y git
cd ~
git clone https://github.com/Rick000000007/Termix-OS-Linux-Distro.git
cd Termix-OS-Linux-Distro
bash install.sh


==========================
RUN TERMIX STORE
==========================

termix-store

Open in browser:
http://localhost:8080

What Termix Store CAN do:
- Install Termux packages
- Remove Termux packages
- Show real-time logs

What Termix Store CANNOT do:
- Install Android Play Store apps
- Replace Play Store
- Install Debian/Ubuntu GUI apps directly (needs proot-distro)


==========================
START XFCE DESKTOP
==========================

termix-xfce


==========================
UNINSTALL
==========================

cd ~/Termix-OS-Linux-Distro
bash uninstall.sh

Note: This removes Termix OS files and shortcuts, but does not uninstall Termux packages automatically.


==========================
PROJECT FILES
==========================

Termix-OS-Linux-Distro/
├── install.sh
├── uninstall.sh
├── termix-store.sh
├── README.md
├── LICENSE
└── config/
    └── starship.toml


==========================
AUTHOR
==========================

ravlav
GitHub: Rick000000007


==========================
LICENSE
==========================

GNU GPLv3
