#!/usr/bin/env bash

# init config files for apt
# so you can run "apt update"

# https://www.debian.org/releases/
# https://wiki.debian.org/DebianExperimental
#debian_release=stable
#debian_release=testing
debian_release=unstable

debian_unstable_experimental=false
#debian_unstable_experimental=true



if [[ "$(id -u )" == "0" ]]; then
  is_root_user=true
else
  is_root_user=false
fi

if $is_root_user; then
  # root user has write-access to /etc
  root_dir=
  apt_etc_dir=etc/apt
  apt_state_dir=var/lib/apt
  apt_cache_dir=var/cache/apt
else
  root_dir=$HOME
  apt_etc_dir=.config/apt
  apt_state_dir=.lib/apt
  apt_cache_dir=.cache/apt
  # alternative paths
  #apt_etc_dir=.local/etc/apt
  #apt_state_dir=.local/lib/apt
  #apt_cache_dir=.local/cache/apt
fi

apt_conf_path="$root_dir/$apt_etc_dir/apt.conf"
sources_list_path="$root_dir/$apt_etc_dir/sources.list"

mkdir -p $root_dir/$apt_etc_dir
mkdir -p $root_dir/$apt_etc_dir/keyrings
mkdir -p $root_dir/$apt_etc_dir/apt.conf.d
mkdir -p $root_dir/$apt_etc_dir/preferences.d

# must be absolute path
keyring_path=$root_dir/$apt_etc_dir/keyrings/debian.org.gpg



apt_conf_path="$root_dir/$apt_etc_dir/apt.conf"
sources_list_path="$root_dir/$apt_etc_dir/sources.list"

echo "writing $apt_conf_path"
{
  echo "Dir \"$root_dir\";"

  # these paths are relative to $root_dir
  echo "Dir::Etc \"$apt_etc_dir\";"
  echo "Dir::State \"$apt_state_dir\";"
  echo "Dir::Cache \"$apt_cache_dir\";"

  #echo 'Dir::Etc "/etc/apt";'
  #echo 'Dir::State "/var/lib/apt";'
  #echo 'Dir::Cache "/var/cache/apt";'

  #echo 'Dir { State "/var/lib/apt"; Etc "/etc/apt"; Cache "/var/cache/apt"; };'
  #echo 'Dir { State "/home/user/.lib/apt"; Etc "/home/user/.config/apt"; Cache "/home/user/.cache/apt"; };'
  #echo 'Dir { State ".lib/apt"; Etc ".config/apt"; Cache ".cache/apt"; };'
  #Dir::State::Lists "/var/lib/apt/lists";
  echo "APT::Default-Release \"$debian_release\";"
  # default is "_apt" which does not exist on nixos linux by default
  echo 'APT::Sandbox::User "nobody";'
} >"$apt_conf_path"



echo "writing $sources_list_path"
{
  for prefix in deb deb-src; do
    echo "$prefix [signed-by=$keyring_path] http://deb.debian.org/debian $debian_release main"
  done
  if [[ "$debian_release" == "unstable" ]] && $debian_unstable_experimental; then
    # unstable + experimental
    # TODO use a different keyring?
    echo
    for prefix in deb deb-src; do
      echo "$prefix [signed-by=$keyring_path] http://deb.debian.org/debian experimental main"
    done
  fi
} >"$sources_list_path"



# add some public keys to $root_dir/$apt_etc_dir/keyrings/

# see also
# https://stackoverflow.com/questions/70789307
# https://stackoverflow.com/questions/68992799

# fix:
# $ sudo apt update
# The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 0E98404D386FA1D9 NO_PUBKEY 6ED0E7B82643E131

declare -A keyring_keys

keyring_name="debian.org"
keyring_keys["$keyring_name"]=""

# gpg: key 73A4F27B8DD47936: public key "Debian Archive Automatic Signing Key (11/bullseye) <ftpmaster@debian.org>" imported
keyring_keys["$keyring_name"]+=" 1F89983E0081FDE018F3CC9673A4F27B8DD47936" # main
#keyring_keys["$keyring_name"]+=" A7236886F3CCCAAD148A27F80E98404D386FA1D9" # sub

# gpg: key B7C5D7D6350947F8: public key "Debian Archive Automatic Signing Key (12/bookworm) <ftpmaster@debian.org>" imported
keyring_keys["$keyring_name"]+=" B8B80B5B623EAB6AD8775C45B7C5D7D6350947F8" # main
#keyring_keys["$keyring_name"]+=" 4CB50190207B4758A3F73A796ED0E7B82643E131" # sub

# gpg: key F8D2585B8783D481: public key "Debian Stable Release Key (12/bookworm) <debian-release@lists.debian.org>" imported
keyring_keys["$keyring_name"]+=" 4D64FEC119C2029067D6E791F8D2585B8783D481"

# TODO add more keys



# get a key's full fingerprint
# based on https://unix.stackexchange.com/a/547605/295986
# example: get_key_fingerprint $HOME/.config/apt/keyrings/debian.org.gpg F8D2585B8783D481
# note: this can return multiple fingerprints
# for the main key and for sub-keys

function get_key_fingerprints() {
  local keyring="$1"
  local short_id="$2"
  gpg --keyring "$keyring" --list-keys --with-colons "$short_id" |
    awk -F: '$1 == "fpr" {print $10;}'
}



set -e # stop on error

for keyring_name in "${!keyring_keys[@]}"; do

  keyring=$root_dir/$apt_etc_dir/keyrings/$keyring_name.gpg
  key_id_list="${keyring_keys[$keyring_name]}"

  echo "updating keyring $keyring"
  a=(
    gpg
    --no-default-keyring
    --keyring $keyring
    --keyserver hkp://keyserver.ubuntu.com:80
    # TODO add more keyservers
    #--ignore-time-conflict
    #--no-options
    #--no-auto-check-trustdb
    #--trust-model always
    --recv-keys $key_id_list
  )
  "${a[@]}"

  # remove backup file created by gpg
  # https://security.stackexchange.com/questions/103332
  [ -e "$keyring"~ ] && rm "$keyring"~

done

if $is_root_user; then
  command_prefix=""
else
  # https://linux.die.net/man/5/apt.conf
  command_prefix="APT_CONFIG=$apt_conf_path "
fi

echo
echo "done init of apt config. next steps:"
echo
echo "update package lists:"
echo "  ${command_prefix}apt update"
echo
echo "show all config variables:"
echo "  ${command_prefix}apt-config dump"
