#!/usr/bin/env bash
set -euf
indir=$(dirname "$1")
inname=$(basename "$1")
out=$(nxgameinfo_cli "$1")
ext=${1##*.}
id=$(awk -F: '/├ Title ID:/{print $2}' <<<"$out" |xargs)
baseid=$(awk -F: '/Base Title ID:/{print $2}' <<<"$out" |xargs)
version=$(awk -F: '/├ Version:/{print $2}' <<<"$out" |xargs)
name=$(awk -F: '/Title Name/{print $2}' <<<"$out" | sed "s/[:']//g" | xargs )
type=$(awk -F: '/Type:/{print $2}' <<<"$out" | xargs)

! test -n "$id" && echo "Title ID cannot be empty!" && exit 1
! test -n "$type" && echo "type cannot be empty!" && exit 1

if test "$type" == Base;then
  ! test -n "$name" && echo "Title Name cannot be empty!" && exit 1
  NAME="$name [$id][v$version].$ext"
elif test "$type" == Update;then
  ! test -n "$name" && echo "Title Name cannot be empty!" && exit 1
  ! test -n "$version" && echo "Version cannot be empty!" && exit 1
  NAME="$name [UPD][$id][v$version].$ext"
elif test "$type" == DLC;then
  dlcname=$(jq -r --arg id "$id" '.[$id].name' < ~/.switch/titles.US.en.json | sed "s/[:']//g")
  if test -n "$dlcname" ;then
    NAME="$dlcname [DLC][$id][v$version].$ext"
  else
    ! test -n "$name" && echo "dlcname cannot be found in titles.US.en.json and $name is empty!" && exit 1
    NAME="$dlcname [DLC][$id][v$version].$ext"
  fi
else
  echo "unknown type '$type'"
  exit 1
fi
newname=$indir/$NAME

if test "$NAME" == "${inname}";then
  echo "name didn't change,doing nothing"
  exit 0
fi
if test -e "$newname" ;then
  echo "'$NAME' already exists, will not override"
  exit 1
fi

if test -n "${FORCE:-}" ;then
  CONFIRM=y
else
  read -p "rename '$inname' to '$NAME' - [y/N]" CONFIRM
fi

if test -n "${FORCE:-}" -o "$CONFIRM" == "y" -o "$CONFIRM" == "Y";then
  mv -nv "$1" "$newname"
else
  echo "bailing out"
  exit 1
fi

