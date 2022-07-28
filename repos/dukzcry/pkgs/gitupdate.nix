{ writeShellScriptBin, git }:

writeShellScriptBin "gitupdate" ''
  export PATH=${git}/bin:$PATH
  git remote update
  UPSTREAM=''${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")
  if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
  elif [ $LOCAL = $BASE ]; then
    echo "Need to pull"
    git pull
    do=0
  elif [ $REMOTE = $BASE ]; then
    echo "Need to push"
  else
    echo "Diverged"
  fi
  [ -z $do ] && exit 1
''
