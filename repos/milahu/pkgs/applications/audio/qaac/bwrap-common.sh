#!/usr/bin/env bash

# dependencies:
# $bin



verbose=

if [ -v QAAC_BWRAP_VERBOSE ] && [ $QAAC_BWRAP_VERBOSE = 1 ]; then
  verbose=-v
fi



pre_bwrap() {
  local f i t l p

  [ ${#pre_mkdir[@]} != 0 ] &&
  mkdir $verbose -p "${pre_mkdir[@]}"

  for f in "${pre_rm[@]}"; do
    [ -e "$f" ] && rm $verbose "$f"
    [ -L "$f" ] && rm $verbose "$f"
  done

  for ((i=0;i<${#pre_symlink[@]};i++)); do
    t="${pre_symlink[$i]}"; : $((i++)) # target
    l="${pre_symlink[$i]}" # link
    # note: this fails if $l exists
    # fix: rewrite_file_path --force
    ln -s -r $verbose "$t" "$l"
  done
}



post_bwrap() {
  local i s d f

  trap '' EXIT
  set +e

  echo

  if [ ${#post_kill[@]} != 0 ]; then
    kill ${post_kill[@]}
  fi

  for ((i=0;i<${#post_mv[@]};i++)); do
    s="${post_mv[$i]}"; : $((i++)) # source
    d="${post_mv[$i]}" # destination
    [ -e "$s" ] && mv $verbose -f "$s" "$d"
  done

  for f in "${post_rm[@]}"; do
    [ -e "$f" ] && rm $verbose "$f"
  done

  for d in "${post_rmdir[@]}"; do
    [ -e "$d" ] && rmdir $verbose "$d"
  done
}



rewrite_dir_path() {
  # rewrite dir path so we can bind it
  # $bin is the program name
  # $a is the argument. ex: -o
  # $v is the value
  v=$(realpath -s "$v")
  v2=$(mktemp -u "$v/$bin.$a.XXXXXXXXXXXXX")
  pre_mkdir+=("$v2")
  post_rmdir+=("$v2") # TODO "rmdir" or "rm -rf"?
  v="$v2"
}



rewrite_file_path() {
  # rewrite file path so we can bind its directory
  # $a is the argument. ex: -o
  # $v is the value -- overwrite this
  local force=0
  #local out=0 # default
  #local in=0 # removed
  local arg
  local dir
  local tmp
  for arg in "$@"; do case "$arg" in
    --force) force=1; continue;;
    #--in) in=1; continue;; # removed
    #--out) out=1; continue;; # default
    *) echo "rewrite_file_path: error: unknown argument ${arg@Q}"; return 1;;
  esac; done
  #if [ $out = 1 ]; then
  # limitation: program cannot seek in the output file
  if [ "$v" = '-' ] || [ "$v" = '/dev/stdout' ]; then
    return # dont rewrite file path
  fi
  v=$(realpath -s "$v") # get absolute path for bwrap bind
  [ $force = 1 ] && pre_rm+=("$v") # replace existing output files
  # with bwrap, we cannot bind non-existing files
  # bind a tempdir on the same filesystem
  # and move the file when program is done
  # compared to the fifo solution
  # this has better performance (no extra "cat" command)
  # and this works with wine (fifo does not work with wine)
  dir=$(basename "$v")
  dir="${dir:0:200}" # limit filename size to 255 bytes
  dir="$(dirname "$v")/$dir".$(mktemp -u XXXXXXXXXX)
  tmp="$dir/$(basename "$v")"
  pre_mkdir+=("$dir")
  pre_symlink+=("$tmp" "$v")
  post_mv+=("$tmp" "$v")
  post_rmdir+=("$dir")
  bwrap_args+=(--bind "$dir" "$dir")
  v="$tmp"
  return
  #fi
  #if [ $in = 1 ]; then
  if false; then
  # limitation: program cannot seek in the input file
  if [ "$v" = '-' ] || [ "$v" = '/dev/stdin' ]; then
    return # dont rewrite file path
  fi
  if ! [ -e "$v" ]; then
    echo "error: missing input file ${v@Q}" >&2
    exit 1
  fi
  v=$(realpath -s "$v") # get absolute path for bwrap bind
  bwrap_args+=(--bind "$v" "$v")
  return
  fi
}



# explicitly set default dirs so we can rewrite dir paths
# this does not work with input dirs
# because the program sees an empty dir
set_default_output_dir() {
  local a="$1"
  local v="$2"
  local n=${a//-/_} # -o -> _o
  local -n arr=$n
  [ ${#arr[@]} != 0 ] && return # dir was set by user
  rewrite_dir_path # use an empty dir
  arr+=("$v")
  A+=("$a" "$v")
}



whitelist_path_opts() {
  # add args to bwrap_args
  local type="$1"; shift
  local opt
  local arr_name
  local val
  local dir
  local tmp
  for opt in $@; do
    arr_name=${opt//-/_}
    local -n arr=$arr_name
    for val in "${arr[@]}"; do
      if [ "$type" = 'if' ]; then # input file
        if [ "$val" = '-' ] || [ "$val" = '/dev/stdin' ]; then continue; fi
        # https://github.com/containers/bubblewrap/issues/372
        # ro-bind a single file
        # --ro-bind path/to/file /where/to/mount/it
        # While that certainly works you are probably better off using a solution like flatpak
        # which handles dynamically adding files into the sandbox for you.
        val=$(realpath -s "$val")
        bwrap_args+=(--ro-bind "$val" "$val")
      elif [ "$type" = 'of' ]; then # output file
        if [ "$val" = '-' ] || [ "$val" = '/dev/stdout' ]; then continue; fi
        #bwrap_args+=(--bind "$val" "$val") # no. bwrap: Can't find source path
        # file path was rewritten by rewrite_file_path
        # so we can bind its dirname
        val=$(realpath -s "$val")
        dir=$(dirname "$val")
        mkdir -p "$dir"
        bwrap_args+=(--bind "$dir" "$dir")
      elif [ "$type" = 'id' ]; then # input directory
        # note: the program can see all contents of this directory
        val=$(realpath -s "$val")
        bwrap_args+=(--ro-bind "$val" "$val")
      elif [ "$type" = 'od' ]; then # output directory
        # dir path was rewritten by rewrite_dir_path
        # so we can bind it
        val=$(realpath -s "$val")
        bwrap_args+=(--bind "$val" "$val")
      else
        echo "whitelist_path_opts: error: unknown type ${type@Q}. expected one of: if of id od" >&2
        return 1
      fi
    done
  done
}
