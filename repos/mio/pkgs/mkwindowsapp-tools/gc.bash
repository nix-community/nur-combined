#! /usr/bin/bash

function print_layer_info() {
  local status=$1
  local id=$2
  local size=$3
  local mutable=$4

  printf "%s\t%s\t%s\t%s\n" $id $size $mutable $status
}

CACHE_DIR="$HOME/.cache/mkWindowsApp"

printf "LAYER ID                                                        \tSIZE\tMUTABLE\tACTION\n"

# API 0
for file in $(ls $CACHE_DIR/*.referrers 2> /dev/null)
do
  filename=$(basename -s .referrers $file)
  size=$(du -h -s "$CACHE_DIR/$filename")
  temp_file=$(mktemp --suffix .mkwindowsapp-gc)

  for ref_path in $(cat $file)
  do
    if [ -e "$ref_path" ]
    then
      echo "$ref_path" >> "$temp_file"
    fi
  done

  if [ -s "$temp_file" ]
  then
    print_layer_info "keeping" $filename $size "?"
    mv "$temp_file" "$file"
  else
    print_layer_info "deleting" $filename $size "?"
    rm -fR "$CACHE_DIR/$filename"
    rm "$file"
    rm "$temp_file"
  fi
done

# API 1
for layer in $(find $CACHE_DIR/ -maxdepth 1 -type d | tail -n +2)
do
  if [ -f "$layer/api" ]
  then
    if [ "$(echo $layer | grep incomplete)" = "" ]
    then
      filename="$(basename $layer)"
      size=$(du -h -s "$CACHE_DIR/$filename" | cut -f 1)
      temp_file=$(mktemp --suffix .mkwindowsapp-gc)
      mutable="?"
      [[ -f $layer/mutable ]] && mutable=$(cat $layer/mutable)

      for ref_path in $(cat $layer/refs)
      do
        if [ -e "$ref_path" ]
        then
          echo "$ref_path" >> "$temp_file"
        fi
      done

      if [ -s "$temp_file" ]
      then
        print_layer_info "keeping" $filename $size $mutable
        mv "$temp_file" "$layer/refs"
      else
        print_layer_info "deleting" $filename $size $mutable
        rm -fR "$layer"
        rm "$temp_file"
      fi
    fi
  fi
done
