# Install-zsh

<b>This script automates the installation of oh-my-zsh, zsh-autosuggestion, and customizes the terminal look like Kali terminal on any distribution and also in Termux.</b>

## Steps

- <b>Install wget, zsh and git first</b>
> apt install wget git zsh -y

```bash
wget https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/install-zsh.sh && bash install-zsh.sh
```
# Fedora (Gnome) Basic Setup

<b>A simple script to make some basic setup in freshly install fedora, like:-</b>
- Install all basic drivers , multimedia codecs 
- Enable RPM Fusion
- Enable colored Emojis 
- Enable Bluetooth Battery 
- Install and setup zsh , zsh-syntax-highlight , zsh-autosuggestion
- Fix cursor size issue 
- Enable extrem battry saver (for laptop)
- Change clock time format to 12h 
- Enable fractional scaling
- Enable new window always launch in center
- Fix browsers shortcut adding issue
- You can change volume steps
- Install some usefull extension :-
  - AppIndicator and KStatusNotifierItem Support by 3v1n0
  - Bluetooth Quick Connect by Extensions Valhalla
  - Blur my Shell by aunetx
  - Bring Out Submenu Of Power Off Button by PRATAP PANABAKA
  - Caffeine by eon
  - Clipboard Indicator by Tudmotu
  - Compiz alike magic lamp effect by hermes83
  - Compiz windows effect by hermes83
  - Coverflow Alt-Tab by dsheeler
  - Dash to Dock by michele_g
  - Emoji Copy by FelipeFTN
  - Expandable Notifications by oklacity
  - Gnome 4x UI Improvements by AXP
  - GSConnect by dlandau
  - Hide Top Bar by tuxor1337
  - Night Theme Switcher by rmnvgr
  - OSD Volume Number by Deminder
  - Removable Drive Menu by fmuellner
  - Search Light by icedman
  - Tiling Assistant by Leleat
  - ransparent Window Moving by Noobsai
  - User Themes by fmuellner
  - Vitals by corecoding
  <br>

```bash
wget https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/fedora-basic-setup.sh && bash fedora-basic-setup.sh
```

# Libadwaita Theme Changer

<b>A simple script to change Libadwaita theme</b>

```bash
wget https://raw.githubusercontent.com/sabamdarif/short-linux-scripts/main/libadwaita-theme-changer.sh && bash libadwaita-theme-changer.sh
```
# Start ssh in termux

- <b>Install `openssh` first</b>
> pkg install openssh -y

```bash
wget https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/termux-ssh && chmod +x termux-ssh && ./termux-ssh
```
- `./termux-ssh` To setup password and start ssh
- `./termux-ssh start` To only start ssh
- `./termux-ssh stop` To stop ssh

# Better termux

<b>Make termux terminal better</b>

```bash
wget https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/better-termux.sh && bash better-termux.sh
```
- setup zsh with systax highltght and autosuggestion
- add new font
- add new home page
- add new color scheme
- change apt with nala
- change cat with bat
- change neofetch with fastfetch
- change ls with eza (with icons)
- change cd with zoxide
- add option to easily start and stop ssh
- SPECIAL COMMAND:-
  - extract: to extract any archive
  - ftext:  Searches for text in all files in the current folder
  - cpg: Copy and go to the directory
  - mvg: Move and go to the directory
  - mkdirg: Create and go to the directory

# Rum

<b>Switch between multiple versions of wine and prefixes via a simple bash script</b>

## Uses
`rum <absolute-path-to-wine-build> </path/to/wineprefix> <wine|winetricks|command> [args...]`

- Ex:- `rum /home/arif/Downloads/caffe-10.8 /home/arif/.wine winecfg`

```bash
wget -O $HOME/.local/bin/rum https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/rum && chmod +x $HOME/.local/bin/rum
```
