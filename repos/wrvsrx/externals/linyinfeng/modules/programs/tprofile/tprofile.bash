function tprofile {
  if [ -z "$tprofile_parent" ]; then
    export tprofile_parent="$(mktemp -d /run/tprofile/XXXXXX)"
    export tprofile_profile="$tprofile_parent/profile"

    export PATH="$tprofile_profile/bin:$PATH"

    trap "rm -r \"$tprofile_parent\"" EXIT

    echo "tprofile created: $tprofile_parent" 1>&2
  fi

  action="$1"
  if [ -n "$1" ]; then
    shift
    nix profile "$action" --profile "$tprofile_profile" "$@"
  else
    echo "$tprofile_parent"
  fi
}

tprofile >/dev/null # initialize
