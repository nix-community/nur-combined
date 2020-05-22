#!/usr/bin/env bash
# This scripts aims to detect which system is running, and bootstrap
# the home configuration accordingly. So far the current setup are
# supported:
# - NixOS (>= 19.03 more or less)
# - Fedora (>= 30)
# - Mac OS X (>= 10.14)

set -e

# Install nix
setup_nix() {
    echo "> Install nix"
    curl https://nixos.org/nix/install | sh
}

# Install home-manager (without running it)
setup_home-manager() {
    echo "> Install home-manager"
    mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
    nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
}

run_home-manager() {
    nix-shell '<home-manager>' -A install
}

# Fedora is "managed" by nix directly
# - bootstrap nix + home-manager
setup_nixos() {
    echo "NixOS detected"
    setup_home-manager
    run_home-manager
}

# Fedora is "managed" mainly using ansible
# - install ansible
# - play the "correct" playbook
# - boostrap nix + home-manager
setup_fedora() {
    echo "Fedora detected"
    if hash nix 2>/dev/null; then
	echo "> nix already present"
    else
	setup_nix
	echo "if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer" >> $HOME/.bashrc
	. $HOME/.bashrc
    fi
    if hash home-manager 2>/dev/null; then
	echo "> home-manager already present"
    else
	setup_home-manager
	echo "export NIX_PATH=$HOME/.nix-defexpr/channels\${NIX_PATH:+:}\$NIX_PATH" >> $HOME/.bashrc
    fi
    if [[ ! -f $HOME/.config/nixpkgs/home.nix ]]; then
       echo "> create a temporary home-manager configuration"
       mkdir -p $HOME/.config/nixpkgs/
       cat > $HOME/.config/nixpkgs/home.nix <<EOF
{
  programs.home-manager.enable = true;
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
}

EOF
    fi
    echo "> setup nix caches"
    mkdir -p $HOME/.config/nix/
    cat > $HOME/.config/nix/nix.conf <<EOF
substituters = http://nix.cache.home https://cache.nixos.org https://shortbrain.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= shortbrain.cachix.org-1:dqXcXzM0yXs3eo9ChmMfmob93eemwNyhTx7wCR4IjeQ=
EOF
    run_home-manager
    echo ". \"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh\"" >> $HOME/.bashrc
    . $HOME/.bashrc
    dnf copr enable evana/fira-code-fonts
    dnf install fira-code-fonts
    echo "> install ansible"
    sudo dnf install -y ansible
    echo "> run playbook"
    ansible-playbook -K ansible/playbook.yml
}

setup_osx() {
    echo "Mac OS X detected"
    if [[ "$kernel_name" == "Darwin" ]]; then
        IFS=$'\n' read -d "" -ra sw_vers < <(awk -F'<|>' '/key|string/ {print $3}' \
                            "/System/Library/CoreServices/SystemVersion.plist")
        for ((i=0;i<${#sw_vers[@]};i+=2)) {
		case ${sw_vers[i]} in
                    ProductName)          darwin_name=${sw_vers[i+1]} ;;
                    ProductVersion)       osx_version=${sw_vers[i+1]} ;;
                    ProductBuildVersion)  osx_build=${sw_vers[i+1]}   ;;
		esac
            }
     fi
}

IFS=" " read -ra uname <<< "$(uname -srm)"
kernel_name="${uname[0]}"
kernel_version="${uname[1]}"
kernel_machine="${uname[2]}"

case "$kernel_name" in
    "Linux" | "GNU")
	if [[ -f "/etc/os-release" || -f "/usr/lib/os-release" ]]; then
                files=("/etc/os-release" "/usr/lib/os-release")

                # Source the os-release file
                for file in "${files[@]}"; do
                    source "$file" && break
                done
		case "$ID" in
		    "nixos")
			setup_nixos ;;
		    "fedora")
			setup_fedora ;;
		esac
	fi ;;
    "Darwin")
	setup_osx ;;
esac
