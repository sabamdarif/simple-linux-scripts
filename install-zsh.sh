#!/bin/bash


R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

check_prefix() {
  case "$PREFIX" in
    *com.termux*)
      read -p $' \e[1;31m[\e[0m\e[1;77m~\e[0m\e[1;31m]\e[0m\e[1;92m Input Username [Lowercase] : \e[0m\e[1;96m\en' user
      echo -e "${W}"
      ;;
    *)
      user=$(whoami)
      ;;
  esac
}

check_file() {
# Check if a file named "install.sh" exists in the current directory
if [ -e "install.sh" ]; then
  echo -e "${R}A file named install.sh already exists in the current directory.${W}"
  
  # Rename the existing file by adding a timestamp suffix
  renamed_file="install_$(date +"%Y%m%d%H%M%S").sh"
  mv "install.sh" "$renamed_file"
  sleep 1.2 
  echo -e "{G}The existing file has been renamed to${W} ${C}$renamed_file${W}."
else
  echo -e "${Y}No file named install.sh found in the current directory.${W}"
fi

}

zsh_setup() {
	clear
	apt install zsh wget curl git -y

	echo "${Y}please wait ......"${W}
	echo "${C}until you get the success massage "${W}
	sleep 1.3
	cd ~/
	check_file
	#echo -e "${C} Now you automaticly login into${W} ${G} ZSH ${W} ${C}so first quit it and wait for${W} ${Y} SETUP SUCCESSFULL MASSAGE ${W}."
	sleep 1.5
	wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
	sed -i -e 's/exec zsh -l/#exec zsh -l/g' install.sh
	#sed -i -e 's/#setup_shell()/setup_shell()/g' ~/install.sh
	bash install.sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="kalistyle"/g' ~/.zshrc
	sed -i -e 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc


}

setup_theme() {
	cat << EOF > ~/.oh-my-zsh/themes/kalistyle.zsh-theme
	local return_code="%(?..%{\$fg[red]%}%? ↵%{\$reset_color%})"
local user_name="$user@localhost"  # Replace with your desired name

local user_host="%B%F{green}┌──(%F{reset}\$user_name%F{green})-%F{green}[%F{reset}%B%{\$fg[blue]%}%~%b%F{blue}%B%F{green}]%F{reset}"

local user_symbol='%B%F{green}%(!.#.└─≽)%F{reset}'

local current_dir="%B%{\$fg[blue]%}%~ %{\$reset_color%}"

local vcs_branch='\$(git_prompt_info)\$(hg_prompt_info)'
local rvm_ruby='\$(ruby_prompt_info)'
local venv_prompt='\$(virtualenv_prompt_info)'

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

PROMPT="\${user_host}\${rvm_ruby}\${vcs_branch}\${venv_prompt}
%{\$fg[yellow]%}\${user_symbol}%{\$reset_color%} "
RPROMPT="%B\${return_code}%b"

ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{\$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[green]%}●%{\$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[yellow]%}"

ZSH_THEME_HG_PROMPT_PREFIX="\$ZSH_THEME_GIT_PROMPT_PREFIX"
ZSH_THEME_HG_PROMPT_SUFFIX="\$ZSH_THEME_GIT_PROMPT_SUFFIX"
ZSH_THEME_HG_PROMPT_DIRTY="\$ZSH_THEME_GIT_PROMPT_DIRTY"
ZSH_THEME_HG_PROMPT_CLEAN="\$ZSH_THEME_GIT_PROMPT_CLEAN"

ZSH_THEME_RUBY_PROMPT_PREFIX="%{\$fg[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{\$reset_color%}"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{\$fg[lightblue]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{\$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="\$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="\$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
EOF

}

print_success() {
	clear
	echo -e "${G}SETUP SUCCESSFULL ${W} ${C} Now Restart the Terminal ${W}"
}

check_prefix
zsh_setup
setup_theme
print_success
