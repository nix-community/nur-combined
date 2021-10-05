#/usr/bin/env bash

set -e

error() {
  printf "$0: $@\n" >&2
  exit 1
}

yesno() {
  printf "$1 [y/n] "
  read -r reply

  if [ "$reply" == "y" ]; then
    ret=1
  else
    ret=0
  fi
}

if [ "$1" == "--help" ]; then
  cat <<EOF

  Installs the Nix package manager and the NixOS-QChem overlay.
EOF

  exit 0
fi

# Check if git is available
command -v git --version > /dev/null || error "Git is not installed. We need git to check out the overlay."

# Needed by the nix installer
command -v curl --version > /dev/null || error "Curl is not installed."
command -v xz --version > /dev/null || error "Xz is not installed."
command -v rsync --version > /dev/null || error "rsync is not installed."

#
# Nix installation
#

has_nix=0
command -v nix --version > /dev/null && has_nix=1

if  [ $has_nix == 0 ]; then
  yesno "\nDo you want to install Nix package manager?"

  if [ $ret == 0 ]; then
    error "Exiting...\n"
  fi

  printf "Download and run Nix installer...\n"
  curl -L https://nixos.org/nix/install | sh -s -- --daemon

  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  printf "\nAdd channel in user environment ...\n"
  nix-channel --add \
    https://nixos.org/channels/nixpkgs-unstable \
    nixpkgs

  nix-channel --update

  # Make user channels available
  yesno "\nWe are going to write the NIX_PATH in your ~/.bashrc"

  if [ $ret == 1 ]; then
    echo export 'NIX_PATH=nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels' >> ~/.bashrc
  fi
fi

#
# Install the overlay
#
overlay_path=~/.config/nixpkgs/overlays/qchem

# make sure the path is clear
if [ -d $overlay_path ]; then
  yesno "\nThere seems to be already an overlay isntalled at $overlay_path.\nDo you want to delete it and reinstall it?"

  if [ $ret == 0 ]; then
    error "Aborting. Please clear $overlay_path and try again."
  fi

  rm -fr $overlay_path
fi

mkdir -p ~/.config/nixpkgs/overlays
git clone https://github.com/markuskowa/NixOS-QChem.git $overlay_path


config_file=~/.config/nixpkgs/config.nix

if [ ! -e $config_file ]; then

  allowUnfree=false
  yesno "\nDo you want to allow the installation of packages with unfree licenses?"
  if [ $ret == 1 ]; then
    allowUnfree=true
  fi

  optAVX=false
  yesno "\nDo you want to build the overlay packages with AVX2 optimizations?"
  if [ $ret == 1 ]; then
    optAVX=true
  fi

  cat > $config_file << EOF
{
  allowUnfree = $allowUnfree;

  qchem-config = {
    # CPU architecture specific tunings, e.g. AVX2
    optAVX = $optAVX;
  };
}
EOF
else
  printf "Config file $config_file exists. Skipping config creation."
fi


cat <<EOF

The Nix and the NixOS-QChem overlay are now installed in you system.
Before you can use it you need refresh your environment by doing a re-login.

For future upgrades please run:
nix-channel --update
and 'git pull' in $overlay_path

EOF

