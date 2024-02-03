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
