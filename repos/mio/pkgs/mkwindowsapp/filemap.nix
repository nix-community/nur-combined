# Returns a bash snippet (string). Do not wrap in writeScript + builtins.readFile:
# that would be IFD and breaks NUR on-nur-search evaluation.
{ rsync }:
''
  map_file () {
    local s=$1
    local d="$WINEPREFIX/$2"

    echo "Mapping $s to $d"

     if [ -e "$d" ]
     then
       local base_dir=$(dirname "$s")

       mkdir -p "$base_dir"

       if [ -f "$d" ]
       then
         cp -v -n "$d" "$s"
       fi

       if [ -d "$d" ]
       then
         ${rsync}/bin/rsync -a --ignore-existing "$d/" "$s"
       fi
     fi

     if [ -e "$s" ]
     then
       local base_dir=$(dirname "$d")
       local base_name=$(basename "$d")

       mkdir -p "$base_dir"
       if [ -e "$d" ] || [ -L "$d" ]
       then
         mv -v "$d" "$base_dir/$base_name.$(uuidgen | head -c 8)"
       fi
       ln -sfn -v "$s" "$d"
     fi
  }

  persist_file () {
    local s="$WINEPREFIX/$1"
    local d="$2"
    local base_dir=$(dirname "$d")

    echo "Persisting $s to $d"
    mkdir -p "$base_dir"

    if [ ! -h "$s" ]
    then
      if [ -f "$s" ]
      then
        cp -v -n "$s" "$d"
      fi

      if [ -d "$s" ]
      then
        ${rsync}/bin/rsync -a --ignore-existing "$s/" "$d"
      fi
    fi
  }
''
