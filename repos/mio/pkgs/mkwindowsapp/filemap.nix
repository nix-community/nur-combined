{
  writeScript,
  rsync,
}:
writeScript "filemap.bash" ''
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

       mv -v "$d" "$base_dir/$base_name.$(uuidgen | head -c 8)"
       mkdir -p "$base_dir"
       ln -s -v "$s" "$d"
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
