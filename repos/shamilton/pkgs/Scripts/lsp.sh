#!/bin/sh
site=$(echo "" | dmenu -p "Site ?")
[ "$site" = "quit" ] && exit 1
[ "$site" = "" ] && exit 1
login=$(echo "" | dmenu -p "Login ?")
[ "$login" = "quit" ] && exit 1
[ "$login" = "" ] && exit 1
printf "Entrer le mot de passe maitre ? "
read -s master_password
@lesspass@/bin/lesspass "$site" "$login" "$master_password" | tr -d '\n' | xclip -in -sel c
echo
echo "Mot de passe enregistré dans le presse-papier."
