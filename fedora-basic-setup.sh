#!/bin/bash
R="$(printf '\033[1;31m')"                           
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
B="$(printf '\033[1;34m')"
C="$(printf '\033[1;36m')"                                        
W="$(printf '\033[1;37m')"

update_sys() {
    sudo dnf update -y
    sudo dnf upgrade -y
}

basic_task() {
      #add rpmfusion repository
  sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf group update core -y
    #installing codecs and other dependencies for playing videos:
  sudo dnf install gstreamer1-plugins-{bad-*,good-*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
  sudo dnf group upgrade --with-optional Multimedia -y
  sudo dnf install libdvdcss libavcodec-freeworld gstreamer1-vaapi -y
   sudo dnf install libva-utils -y
  sudo dnf install *-firmware -y
  sudo dnf groupupdate sound-and-video
  sudo dnf swap ffmpeg-free ffmpeg totem totem-video-thumbnailer --allowerasing -y
}

tweaks() {
    sudo dnf install gnome-tweaks -y
    sudo dnf install google-noto-emoji-color-fonts -y
    if [[ ! -d "$HOME/.config/fontconfig" ]]; then
        mkdir -p "$HOME/.config/fontconfig"
        mkdir -p "$HOME/.config/fontconfig/conf.d"
           cat <<EOF > "$HOME/.config/fontconfig/conf.d/color-emoji.conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig> 
  <!-- Use Google Emojis -->
  <match target="pattern">
    <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
    <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  </match>
</fontconfig>
EOF
    fi
    flatpak install flathub it.mijorus.smile
  #sudo flatpak override --env=GTK_THEME=my-theme 
  #sudo flatpak override --env=ICON_THEME=my-icon-theme
  sudo flatpak override --reset
   if [[ ! -d "$HOME/.themes/" ]]; then
        mkdir -p "$HOME/.themes/"
        sudo flatpak override --filesystem=$HOME/.themes
    fi
  if [[ ! -d "$HOME/.icons/" ]]; then
        mkdir -p "$HOME/.themes/"
        sudo flatpak override --filesystem=$HOME/.icons
    fi
    sudo flatpak override --filesystem=xdg-config/gtk-4.0
    #fixing shortcut adding issue for browser
installed_apps=$(flatpak list --app --columns=ref)
keywords=("com.google.Chrome" "com.microsoft.Edge" "com.brave.Browser" "ru.yandex.Browser" "org.chromium.Chromium" "com.opera.Opera")
for keyword in "${keywords[@]}"; do
  matched_apps=$(echo "$installed_apps" | grep -i "$keyword")
  if [ -n "$matched_apps" ]; then
    while IFS= read -r package_name; do
      package_name=$(echo "$package_name" | awk -F/ '{print $1}')
      echo "Found app: $package_name"
     flatpak override --user --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons "$package_name"
    done <<< "$matched_apps"
  fi
done
sudo sed -i 's/#Experimental = true/ Experimental = true/g' /etc/bluetooth/main.conf
sudo systemctl restart bluetooth
#adding display scale dropdown menu (fractional scaling )
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
#turn off -> gsettings set org.gnome.mutter experimental-features "[]"
#enable all new apps launch in center window 
gsettings set org.gnome.mutter center-new-windows true
#set time format to 12h 
gsettings set org.gnome.desktop.interface clock-format '12h'
#fix gsconnect file access issue
git clone https://github.com/fjueic/gsconnect-mount-manager.git
cd gsconnect-mount-manager
chmod +x install.sh
./install.sh

#volume over 100 persent
# open dconf editor
# go to /org/gnome/desktop/sound/
# enable Allow volume above 100%
}

usefull_settings_and_apps() {
    sudo dnf install flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo dnf install gnome-shell-extensions gnome-extensions-app -y
    flatpak install flathub com.mattjakeman.ExtensionManager
    # GDM settings 
    flatpak install flathub io.github.realmazharhussain.GdmSettings -y
    flatpak install flathub io.gitlab.adhami3310.Converter -y
    flatpak install flathub org.gnome.Shotwell -y
    flatpak install flathub fr.handbrake.ghb -y
    sudo dnf install vlc -y
    sudo dnf install file-roller -y
    sudo dnf install qt6ct qt5ct -y
     #system monitor
     read -p "${Y} Do you want to install a system monitor and cleaner? (y/n): "${W} mon_choice
     if [ "$mon_choice" = "y" ]; then
     echo "${G} Instaling System Monitor (STACER)"${W}
     sudo dnf install stacer -y
     echo "${G} Instaling System Cleaner (bleachbit)"${W}
     sudo dnf install bleachbit -y
     else
     echo "${G} Canceling System Monitor cleaner install ...."
     sleep 1
     fi
  #set custome cursor size 
  read -p "${Y} Do you want to change the cursor size? (y/n): "${W} choice_cur
while true; do
    if [ "$choice_cur" = "y" ]; then
        current_size=$(gsettings get org.gnome.desktop.interface cursor-size)
        echo "${G} The cursor size is: $current_size"${W}
        read -p "${Y} Enter the new cursor size: "${W} new_size
        gsettings set org.gnome.desktop.interface cursor-size "$new_size"
        echo "${G} Cursor size set to $new_size"${W}
        read -p "${Y} Do you want to save these changes? (y/n): "${W} save_changes
        if [ "$save_changes" = "y" ]; then
            echo "${G} Changes saved."${G}
            break
        fi
    elif [ "$choice_cur" = "n" ]; then
        break
    else
        echo "${R} Invalid input. Please enter 'y' or 'n'."${W}
    fi
done
#change volume steps
read -p "${G} Do you want to change volume steps? (y/n): "${W} choice_vol
choice_vol=${choice_vol:-y}
if [ "$choice_vol" = "y" ]; then
    current_steps=$(gsettings get org.gnome.settings-daemon.plugins.media-keys volume-step)
    echo "${G} The cursor size is: $current_steps"${W}
    read -p "${Y} Enter the new steps value: "${W} new_steps_value
    gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step $new_steps_value
    
    echo "${C} volume steps set to $new_steps_value"${W}
fi
sudo dnf install pavucontrol -y
sudo dnf install fedora-workstation-repositories -y
# extrem poweer saving
read -p "${Y} Do you want to setup extreme battery saving (for laptop)? (y/n): "${W} choice_extbattery
#https://github.com/AdnanHodzic/auto-cpufreq
 if [ "$choice_extbattery" = "y" ]; then
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer

cd 
rm -rf auto-cpufreq
else
echo "${G}Canceling extreme battery saving setup..."${W}
fi
read -p "${Y}Do you want to setup nautilus tools (add more usefull features in nautilus)(y/n): "${W} nautilus_tools
nautilus_tools=${nautilus_tools:-y}
if [[ "$nautilus_tools" == "y" ]]; then
echo "${G}Setting up nautilus-scripts" ${W}
dnf copr enable tomaszgasior/mushrooms
sudo dnf install nautilus-admin -y
sudo dnf install sushi -y
sudo dnf install --allowerasing p7zip ImageMagick xz poppler-utils ffmpeg-free genisoimage foremost testdisk rdfind squashfs-tools -y
sudo dnf install --allowerasing bzip2 gzip tar unzip zip pandoc jpegoptim optipng ghostscript qpdf testdisk perl-base rhash -y
cd $HOME
git clone https://github.com/cfgnunes/nautilus-scripts.git
cd $HOME/nautilus-scripts
bash install.sh
else
echo "${G}Canceling nautilus-tools setup"${W}
fi
}

install_extensions() {
  array=(appindicatorsupport@rgcjonas.gmail.com bluetooth-quick-connect@bjarosze.gmail.com blur-my-shell@aunetx caffeine@patapon.info clipboard-indicator@tudmotu.com compiz-alike-magic-lamp-effect@hermes83.github.com compiz-windows-effect@hermes83.github.com CoverflowAltTab@palatis.blogspot.com dash-to-dock@micxgx.gmail.com desktop-cube@schneegans.github.com desktop-lyric@tuberry ding@rastersoft.com drive-menu@gnome-shell-extensions.gcampax.github.com hidetopbar@mathieu.bidon.ca emoji-copy@felipeftn expandable-notifications@kaan.g.inam.org forge@jmmaranan.com gnome-ui-tune@itstime.tech gsconnect@andyholmes.github.io hidetopbar@mathieu.bidon.ca nightthemeswitcher@romainvigier.fr osd-volume-number@deminder rounded-window-corners@yilozt  search-light@icedman.github.com simplenetspeed@biji.extension tiling-assistant@leleat-on-github transparent-window-moving@noobsai.github.com user-theme@gnome-shell-extensions.gcampax.github.com Vitals@CoreCoding.com just-perfection-desktop@just-perfection impatience@gfxmonk.net)

for i in "${array[@]}"
do
    #VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    echo "${G} Installing $i"${W}
    #wget -O ${i}.zip "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
    #gnome-extensions install --force ${i}.zip
    if ! gnome-extensions list | grep --quiet ${i}; then
    echo "${G}Installing Extension ${B} ${i}"${W}
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${i}
        sleep 3
    fi
    #gnome-extensions enable ${i}
    #rm -f "${i}.zip"
done
}

install_zsh_terminal_utilities() {
    read -p "${G} Do you want to zsh , zsh syntax highlight , zsh autusuggestion? (y/n): "${W} zsh_choice
    zsh_choice=${zsh_choice:-y}
    if [ "$zsh_choice" = "y" ]; then
        shell_name="zsh"
        sudo dnf install wget -y && wget https://raw.githubusercontent.com/sabamdarif/short-linux-scripts/main/install-zsh.sh && bash install-zsh.sh
        rm install-zsh.sh
    else
        shell_name="bash"
        echo "${G} Canceling zsh setup..."${W}
        sleep 1
    fi
    
    read -p "${Y}Do you want to add terminal utilities (y/n): "${W} terminal_utilities
    terminal_utilities=${terminal_utilities:-y}
    if [[ "$terminal_utilities" == "y" ]]; then
        sudo dnf install zoxide bat eza trash-cli -y
        cat <<EOF >> "$HOME/.${shell_name}rc"
alias dnf='sudo dnf \$@'
alias cat='bat \$@'
alias ls='eza --icons \$@'
alias neofetch='fastfetch'
export GPG_TTY=\$(tty)
#set zoxide as cd
eval "\$(zoxide init --cmd cd zsh)"
# Alias's to change the directory
alias web='cd /var/www/html'
# Alias's to modified commands
alias rm='trash -v'
alias trashlist='trash-list'
alias cleantrash='trash-empty'
alias mkdir='mkdir -p'
alias vi='nvim'
alias vim='nvim'
# Search files in the current folder
alias f="find . | grep "
#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "\$@"; do
		if [ -f "\$archive" ]; then
			case \$archive in
			*.tar.bz2) tar xvjf \$archive ;;
                        *.tar.xz) tar -xvf \$archive ;;
                        *.tar.gz) tar -xzvf \$archive ;;
			*.tar.gz) tar xvzf \$archive ;;
			*.bz2) bunzip2 \$archive ;;
			*.rar) rar x \$archive ;;
			*.gz) gunzip \$archive ;;
			*.tar) tar xvf \$archive ;;
			*.tbz2) tar xvjf \$archive ;;
			*.tgz) tar xvzf \$archive ;;
			*.zip) unzip \$archive ;;
			*.Z) uncompress \$archive ;;
			*.7z) 7z x \$archive ;;
			*) echo "don't know how to extract '\$archive'..." ;;
			esac
		else
			echo "'\$archive' is not a valid file!"
		fi
	done
}
# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "\$1" *
	grep -iIHrn --color=always "\$1" . | less -r
}
# Copy file with a progress bar
cpp() {
	set -e
	strace -q -ewrite cp -- "\$1" "\$2" 2>&1 |
		awk '{
	count += \$NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size="\$(stat -c '%s' "\$1")" count=0
}
# Copy and go to the directory
cpg() {
	if [ -d "\$2" ]; then
		cp "\$1" "\$2" && cd "\$2"
	else
		cp "\$1" "\$2"
	fi
}
# Move and go to the directory
mvg() {
	if [ -d "\$2" ]; then
		mv "\$1" "\$2" && cd "\$2"
	else
		mv "\$1" "\$2"
	fi
}
# Create and go to the directory
mkdirg() {
	mkdir -p "\$1"
	cd "\$1"
}
EOF
        echo "${G}Terminal utilities setup completed"
    else
        echo "${G}Canceling terminal utilities setup"
    fi
}

update_sys
basic_task
tweaks
install_zsh_terminal_utilities
usefull_settings_and_apps
install_extensions
