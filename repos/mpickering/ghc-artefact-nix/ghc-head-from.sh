#! /usr/bin/env bash

default_nix=https://github.com/mpickering/ghc-artefact-nix/archive/master.tar.gz
if [ -f $(dirname $0)/default.nix ]; then
  default_nix=$(dirname $0)
fi

re='^[0-9]+$'
if [[ $1 =~ $re ]] ;
then
	# If a MR number is passed then lookup which branch to get artefacts from.
  REQ=$(curl -s https://gitlab.haskell.org/api/v4/projects/1/merge_requests/$1)
  PARSED_BRANCH=$(echo $REQ | jq -r '.source_branch')
  PARSED_PROJECT=$(echo $REQ | jq -r '.source_project_id')
  PROJ_REQ=$(curl -s https://gitlab.haskell.org/api/v4/projects/$PARSED_PROJECT)
	PARSED_FORK=$(echo $PROJ_REQ | jq -r '.namespace.path')
	MR_TITLE=$(echo $REQ | jq -r '.title')
	echo "Fetching from MR: $MR_TITLE"
elif ! [ -z "$1" ]; then
  # Assume the argument is a URL
  echo "Fetching artefact from $1"
  nix run -f $default_nix \
    --argstr url $1 \
    ghcHEAD cabal-install gcc binutils-unwrapped
  exit 0
fi
# Set the default values if there was no parameter
FORK=''${PARSED_FORK:-ghc}
BRANCH=''${PARSED_BRANCH:-master}
echo "Fetching artefact from $FORK/$BRANCH"
nix run -f $default_nix \
  --argstr fork $FORK \
  --argstr branch $BRANCH \
   ghcHEAD cabal-install gcc binutils-unwrapped
