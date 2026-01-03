WA_API="1"
_wa_cache_dir="$HOME/.cache/mkWindowsApp"
_wa_winearch=""
_wa_build_hash=""

# Library initialization
wa_init () {
  _wa_winearch=$1
  _wa_build_hash=$2
}

# Layers API
_wa_get_layer () {
  local input_hash=$1

  printf "%s" "$_wa_cache_dir/$input_hash"
}

wa_init_layer () {
  local input_hash=$1
  local reference=$2
  local layer_dir=$(_wa_get_layer $input_hash)
  local incomplete_layer_dir="$layer_dir.incomplete"

  if [ ! -d "$layer_dir" ]
  then
    if [ ! -d "$incomplete_layer_dir" ]
    then
      mkdir -p "$incomplete_layer_dir/wineprefix"

      pushd "$incomplete_layer_dir" > /dev/null
      echo "$WA_API" > api
      echo "$reference" > refs
      chmod ugo-w api
      popd > /dev/null
    fi
  else
      local tmp_refs=$(mktemp --suffix=.mkwindowsApp)
      cat "$layer_dir/refs" > "$tmp_refs"
      echo "$reference" >> "$tmp_refs"
      cat "$tmp_refs" | sort | uniq > "$layer_dir/refs"
      rm -f "$tmp_refs"
  fi

  printf "%s" $layer_dir
}

wa_close_layer () {
  local input_hash=$1
  local make_writeable=$2
  local layer_dir=$(_wa_get_layer $input_hash)
  local incomplete_layer_dir="$layer_dir.incomplete"

  if [ -d "$incomplete_layer_dir" ]
  then
    pushd "$(dirname $incomplete_layer_dir)"
    mv "$(basename $incomplete_layer_dir)" "$(basename $layer_dir)"
    popd

    if [ "$make_writeable" == "1" ]
    then
      echo "1" > "$layer_dir/mutable"
    else
      echo "0" > "$layer_dir/mutable"
    fi
  fi
}

# Wine bottle API

wa_get_bottle_dir () {
  local windows_layer=$1
  local app_layer=$2

  if [[ -d "$windows_layer" && -d "$app_layer" ]]
  then
     # Use a fixed path based on the "build"; The hash of the Windows and app layers.
     local tmp_dir="/tmp/$_wa_build_hash.mkwindowsapp"

     mkdir -p $tmp_dir
     printf "%s" "$tmp_dir"
  else
    # Use a temporary directory, since this bottle is being used to build a layer.
    printf "%s" $(mktemp -d --suffix=.mkwindowsApp)
  fi
}

wa_is_bottle_initialized () {
  local windows_layer=$1
  local app_layer=$2
  local bottle_dir=$(wa_get_bottle_dir $windows_layer $app_layer)

  if [ -e "$bottle_dir/wineprefix/.initialized" ]
  then
    printf "%s" "1"
  else
    printf "%s" "0"
  fi
}

wa_init_bottle () {
  local windows_layer=$1
  local app_layer=$2
  local run_layer=$3
  local tmp_dir=$(wa_get_bottle_dir $windows_layer $app_layer)
  local upper_dir="$tmp_dir/upper_dir"
  local wineprefix="$tmp_dir/wineprefix"

  if [ -d "$windows_layer" ]
  then
    echo "overlay" > "$tmp_dir/type"

    if [ -d "$app_layer" ]
    then
      if [ -d "$run_layer" ]
      then
        upper_dir="$run_layer/wineprefix"
      fi

      mkdir -p "$upper_dir"
      mkdir -p "$wineprefix"

      unionfs -o cow $upper_dir=RW:$app_layer/wineprefix=RO:$windows_layer/wineprefix=RO $wineprefix
      touch "$wineprefix/.initialized"
    else
      upper_dir="$app_layer.incomplete/wineprefix"
      mkdir -p "$wineprefix"

      unionfs -o cow $upper_dir=RW:$windows_layer/wineprefix=RO $wineprefix
    fi

  else
    echo "plain" > "$tmp_dir/type"
    pushd "$tmp_dir" > /dev/null
    ln -s "$windows_layer.incomplete/wineprefix" wineprefix 
    popd > /dev/null
  fi

  printf "%s" "$tmp_dir"
}

wa_remove_bottle () {
  local bottle_dir=$1
  local wineprefix="$bottle_dir/wineprefix"

  if [ -d "$bottle_dir" ]
  then
    local type=$(cat $bottle_dir/type)

    if [ "$type" = "overlay" ]
    then
      fusermount -u $wineprefix
      rm -fR "$bottle_dir"
    else
      rm -fR "$bottle_dir"
    fi
  fi
}

wa_with_bottle () {
  local bottle_dir=$1
  local dlloverrides=$2
  local callback=$3
  export WINEARCH="$_wa_winearch"
  export WINEPREFIX="$bottle_dir/wineprefix"
  export WINEDLLOVERRIDES="winemenubuilder.exe=d;$dlloverrides"

  ($callback)
}
