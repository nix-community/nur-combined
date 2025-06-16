function tprofile
  if [ -z $tprofile_profile ]
    set --global --export tprofile_parent (mktemp -d /run/tprofile/XXXXXX)
    set --global --export tprofile_profile $tprofile_parent/profile

    set --global --prepend fish_user_paths $tprofile_profile/bin

    trap "rm -r \"$tprofile_parent\"" EXIT

    echo "tprofile created: $tprofile_parent" 1>&2
  end

  if set --query argv[1]
    nix profile $argv[1] --profile $tprofile_profile $argv[2..]
  else
    echo $tprofile_parent
  end
end

tprofile > /dev/null # initialize
