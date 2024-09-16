#!/data/data/com.termux/files/usr/bin/bash

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[0m')"
C="$(printf '\033[1;36m')"

function check_and_backup() {
	local file
	local files_folders
    for files_folders in "$@"; do
        for file in $files_folders; do
            if [[ -e "$file" ]]; then
            local date_str=$(date +"%d-%m-%Y")
			local backup="${file}-${date_str}.bak"
			    if [[ -e "$backup" ]]; then
				echo "${G}Backup file ${C}${backup} ${G}already exists"${W}
				echo
				fi
		    echo "${G}backing up file ${C}$file"${W}
			mv "$1" "$backup"
            fi
        done
    done
}

function check_and_create_directory() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
    fi
}

function check_and_delete() {
    local file
    for files_folders in "$@"; do
        for file in $files_folders; do
            if [[ -e "$file" ]]; then
                if [[ -d "$file" ]]; then
                    rm -rf "$file" >/dev/null 2>&1
                elif [[ -f "$file" ]]; then
                    rm "$file" >/dev/null 2>&1
                fi
            fi
        done
    done
}

function package_install_and_check() {
	packs_list=($@)
for package_name in "${packs_list[@]}"; do
    echo "${R}[${W}-${R}]${G}${BOLD} Installing package: ${C}$package_name ${W}"
	if type -p pacman >/dev/null 2>&1; then
	    if pacman -Qi "$package_name" >/dev/null 2>&1; then
		pacman -Sy --noconfirm --overwrite '*' "$package_name"
		else
		pacman -Sy --noconfirm "$package_name"
		fi
	else
	   if dpkg -s "$package_name" >/dev/null 2>&1; then
		pkg reinstall "$package_name" -y
	   else
	    pkg install "$package_name" -y
	   fi
	fi
    if [ $? -ne 0 ]; then
        echo "${R}[${W}-${R}]${G}${BOLD} Error detected during installation of: ${C}$package_name ${W}"
	  if type -p pacman >/dev/null 2>&1; then
	    pacman -Sy --overwrite '*' $package_name
	    pacman -Sy --noconfirm $package_name
	  else
        apt --fix-broken install -y
        dpkg --configure -a
	  fi
        pkg install "$package_name" -y
    fi
   if type -p pacman >/dev/null 2>&1; then
     if pacman -Qi "$package_name" >/dev/null 2>&1; then
        echo "${R}[${W}-${R}]${G} $package_name installed successfully ${W}"
    else
        if type -p "$package_name" &>/dev/null || [ -e "$PREFIX/bin/$package_name"* ] || [ -e "$PREFIX/bin/"*"$package_name" ]; then
            echo "${R}[${W}-${R}]${C} $package_name ${G}installed successfully ${W}"
        fi
    fi
   else
    if dpkg -s "$package_name" >/dev/null 2>&1; then
        echo "${R}[${W}-${R}]${G} $package_name installed successfully ${W}"
    else
        if type -p "$package_name" &>/dev/null || [ -e "$PREFIX/bin/$package_name"* ] || [ -e "$PREFIX/bin/"*"$package_name" ]; then
            echo "${R}[${W}-${R}]${C} $package_name ${G}installed successfully ${W}"
        fi
    fi
   fi
done
echo ""
}

if [[ $HOME != *termux* ]]; then 
	echo "${R}${BOLD}Please run it inside termux"${W}
	exit 0
	fi
echo "${R}[${W}-${R}]${G}${BOLD} Updating System...."${W}
	echo
	if type -p pacman >/dev/null 2>&1; then
	pacman -Syu --noconfirm
	else
	echo "${G}${BOLD}Selecting best termux packages mirror please wait"${W}
	unlink "$PREFIX/etc/termux/chosen_mirrors" &>/dev/null
	ln -s "$PREFIX/etc/termux/mirrors/all" "$PREFIX/etc/termux/chosen_mirrors" &>/dev/null
	pkg --check-mirror update
	pkg update -y -o Dpkg::Options::="--force-confnew"
	pkg upgrade -y -o Dpkg::Options::="--force-confnew"
	fi

package_install_and_check "zsh git wget"
wget https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/install-zsh.sh && bash install-zsh.sh
clear
package_install_and_check "openssh"
wget -O $PREFIX/bin/termux-ssh https://raw.githubusercontent.com/sabamdarif/simple-linux-scripts/main/termux-ssh
chmod +x $PREFIX/bin/termux-ssh
check_and_backup "$PREFIX/etc/motd"
check_and_backup "$PREFIX/etc/motd-playstore"
check_and_backup "$PREFIX/etc/motd.sh"
wget -O $PREFIX/etc/motd.sh https://raw.githubusercontent.com/sabamdarif/termux-desktop/main/other/motd.sh

if grep -q "motd.sh$" "$PREFIX/etc/termux-login.sh"; then
        sed -i "s|.*motd\.sh$|bash $PREFIX/etc/motd.sh|" "$PREFIX/etc/termux-login.sh"
    else
        echo "bash $PREFIX/etc/motd.sh" >> "$PREFIX/etc/termux-login.sh"
    fi
check_and_create_directory "$HOME/.termux"
check_and_backup "$HOME/.termux/colors.properties"
wget -O $HOME/.termux/colors.properties https://raw.githubusercontent.com/sabamdarif/termux-desktop/main/other/colors.properties

echo "${R}[${W}-${R}]${G}${BOLD} Installing Fonts..."${W}
	package_install_and_check "nerdfix fontconfig-utils"
	check_and_create_directory "$HOME/.fonts"
	check_and_backup "$HOME/.termux/font.ttf"
	wget -O $HOME/font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/0xProto.zip
	unzip "$HOME/font.zip" -d "$HOME/.fonts"
	check_and_delete "$HOME/.fonts/README.md $HOME/.fonts/LICENSE"
	rm $HOME/font.zip
	cp $HOME/.fonts/0xProtoNerdFont-Regular.ttf $HOME/.termux/font.ttf
	fc-cache -f
	check_and_create_directory "$HOME/.config/fastfetch"
	wget -O $HOME/.config/fastfetch/config.jsonc https://raw.githubusercontent.com/sabamdarif/termux-desktop/main/other/config.jsonc 

if type -p pacman >/dev/null 2>&1; then
	package_install_and_check "bat eza zoxide fastfetch"
	else
	package_install_and_check "nala bat eza zoxide fastfetch"
cat <<'EOF' >> "$HOME/.zshrc"
alias apt='nala $@'
alias pkg='nala $@'
EOF
fi
cat <<'EOF' >> "$HOME/.zshrc"
alias cat='bat $@'
alias ls='eza --icons $@'
alias mkdir='mkdir -p'
alias neofetch='fastfetch'
alias startssh='termux-ssh'
alias stopssh='termux-ssh stop'
#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
                        *.tar.xz) tar -xvf $archive ;;
                        *.tar.gz) tar -xzvf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
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
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}
# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}
# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}
# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}
# set zoxide as cd
eval "$(zoxide init --cmd cd zsh)"
EOF

clear
echo -e "${G}Setup Successful\nNow restart termux"${W}