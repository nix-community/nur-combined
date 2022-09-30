#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bitwarden-cli git gnupg jq nix

# Command failure is script failure
set -e

BOLD_RED="\e[0;1;31m"
BOLD_BLUE="\e[0;1;34m"
BOLD_GREEN="\e[0;1;32m"

RESET="\e[0m"

DEST="$HOME/.config/nixpkgs"
BW_SESSION=""

warn() {
    echo -e "${BOLD_RED}$1${RESET}"
}

info() {
    echo -e "${BOLD_BLUE}$1${RESET}"
}

success() {
    echo -e "${BOLD_GREEN}$1${RESET}"
}

set_perm() {
    # $1: destination
    # $2: permissions

    chmod "$2" "$1" && success "--> Set permission of $1 to $2"
}

get_doc() {
    # $1: name of folder which contains the wanted document
    # $2: name of the document
    # $3: destination
    # $4: permissions

    local FOLDER_ID
    local NOTES
    FOLDER_ID="$(bw list folders |
        jq '.[] | select(.name == "'"$1"'") | .id' |
        cut -d'"' -f2)"

    NOTES="$(bw list items --folderid "$FOLDER_ID" |
        jq '.[] | select(.name == "'"$2"'") | .notes' |
        cut -d'"' -f2)"

    printf "%b" "$NOTES" > "$3"
    set_perm "$3" "$4"
}

get_ssh() {
    mkdir -p "$HOME/.ssh" && info "-> Creating .ssh folder."
    chmod 700 "$HOME/.ssh" && info "--> Modifying permissions of .ssh folder."

    get_doc "SysAdmin/SSH" "shared-key-public" "$HOME/.ssh/shared_rsa.pub" 644
    get_doc "SysAdmin/SSH" "shared-key-private" "$HOME/.ssh/shared_rsa" 600
    get_doc "SysAdmin/SSH" "agenix-public" "$HOME/.ssh/id_ed25519.pub" 644
    get_doc "SysAdmin/SSH" "agenix-private" "$HOME/.ssh/id_ed25519" 600
}

get_pgp() {
    local KEY
    KEY=key.asc
    get_doc "SysAdmin/PGP" "pgp-key-private" "$KEY" 644

    gpg \
        --pinentry-mode loopback \
        --import "$KEY"
    printf '5\ny\n' |
        gpg \
            --command-fd 0 \
            --pinentry-mode loopback \
            --edit-key 'Bruno BELANYI' \
            trust
    rm "$KEY"
}

get_creds() {
    BW_SESSION="$(bw login --raw || bw unlock --raw)"
    export BW_SESSION

    get_ssh
    get_pgp
}

setup_gpg() {
    info 'Setting up loopback pinentry for GnuPG'
    echo "allow-loopback-pinentry" > ~/.gnupg/gpg-agent.conf

    info 'Signing dummy message to ensure GnuPG key is usable by `git-crypt`'
    echo whatever | gpg --clearsign --armor --pinentry loopback --output /dev/null
}

[ -z "$NOCREDS" ] && get_creds
[ -z "$NOGPG" ] && setup_gpg

nix --experimental-features 'nix-command flakes' develop
