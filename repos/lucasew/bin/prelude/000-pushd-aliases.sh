function _conditional_pushd {
  while [ $# -gt 0 ]; do
    if [ -d "$1" ]; then
      pushd "$1" 2>&1 >/dev/null
      return 0
    else
      shift
    fi
  done
  return 1
}


function dotfiles {
  _conditional_pushd "$(sd d root)" 
}

function nixpkgs {
  _conditional_pushd nixpkgs ~/nixpkgs ~/WORKSPACE/OPENSOURCE-contrib/nixpkgs
}

function gcd {
  _conditional_pushd "$(sd g root)/$*"
}

function rcd {
  selected_repo="$(find ~/WORKSPACE -maxdepth 3 -type d  -name '.git' | fzf)"
  if [ ! -z $selected_repo ]; then
    _conditional_pushd "$selected_repo/.."
  else
    echo no repo selected >&2
  fi
}
