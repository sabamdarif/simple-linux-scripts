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
  sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
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
    flatpak install flathub io.github.realmazharhussain.GdmSettings
    sudo dnf install vlc -y
     #system monitor
     read -p "${Y} Do you want to install a system monitor? (y/n): "${W} mon_choice
     if [ "$mon_choice" = "y" ]; then
     echo "${G} Instaling System Monitor (STACER)"${W}
     sudo dnf install stacer -y
     else
     echo "${G} Canceling Sys Monitor install ...."
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
}

install_extensions() {
  array=( appindicatorsupport@rgcjonas.gmail.com bluetooth-quick-connect@bjarosze.gmail.com blur-my-shell@aunetx caffeine@patapon.info clipboard-indicator@tudmotu.com compiz-alike-magic-lamp-effect@hermes83.github.com compiz-windows-effect@hermes83.github.com CoverflowAltTab@palatis.blogspot.com dash-to-dock@micxgx.gmail.com desktop-cube@schneegans.github.com desktop-lyric@tuberry ding@rastersoft.com drive-menu@gnome-shell-extensions.gcampax.github.com hidetopbar@mathieu.bidon.ca emoji-copy@felipeftn expandable-notifications@kaan.g.inam.org forge@jmmaranan.com gnome-ui-tune@itstime.tech gsconnect@andyholmes.github.io hidetopbar@mathieu.bidon.ca nightthemeswitcher@romainvigier.fr osd-volume-number@deminder rounded-window-corners@yilozt search-light@icedman.github.com simplenetspeed@biji.extension tiling-assistant@leleat-on-github transparent-window-moving@noobsai.github.com user-theme@gnome-shell-extensions.gcampax.github.com Vitals@CoreCoding.com )

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

install_zsh() {
read -p "${G} Do you want to zsh , zsh syntax highlight , zsh autusuggestion? (y/n): "${W} zsh_choice
if [ "$zsh_choice" = "y" ]; then
sudo dnf install wget -y && wget https://raw.githubusercontent.com/sabamdarif/short-linux-scripts/main/install-zsh.sh && bash install-zsh.sh
rm install-zsh.sh
else
echo "${G} Canceling zsh setup..."${W}
sleep 1

}


update_sys
basic_task
tweaks
install_zsh
usefull_settings_and_apps
install_extensions
