#!/bin/bash

if [[ $1 == "--reset" ]]; then
    echo -e "\n***\nResetting theme to default!\n***\n"
    rm ~/.config/gtk-4.0/gtk.css
    rm ~/.config/gtk-4.0/gtk-dark.css
    rm -rf ~/.config/gtk-4.0/assets
    rm -rf ~/.config/assets
else
    all_themes=(~/.themes/*)
    echo "Select theme: "
    for (( i=0; i<${#all_themes[@]}; i++ )); do
        theme=$(basename "${all_themes[$i]}")
        echo "$((i+1)). $theme"
    done
    echo "e. Exit"
    read -p "Your choice: " chk
    case $chk in
        "e")
            echo "Bye bye!"
            ;;
        *)
            chk_value=$((chk-1))
            chk_theme=$(basename "${all_themes[$chk_value]}")
            echo -e "\n***\nChoosed $chk_theme\n***\n"
            echo "Removing previous theme..."
            rm ~/.config/gtk-4.0/gtk.css
            rm ~/.config/gtk-4.0/gtk-dark.css
            rm -rf ~/.config/gtk-4.0/assets
            rm -rf ~/.config/assets
            echo "Installing new theme..."
            ln -s "${all_themes[$chk_value]}/gtk-4.0/gtk.css" ~/.config/gtk-4.0/gtk.css
            ln -s "${all_themes[$chk_value]}/gtk-4.0/gtk-dark.css" ~/.config/gtk-4.0/gtk-dark.css
            ln -s "${all_themes[$chk_value]}/gtk-4.0/assets" ~/.config/gtk-4.0/assets
            ln -s "${all_themes[$chk_value]}/assets" ~/.config/assets
            echo "Done."
            ;;
    esac
fi
