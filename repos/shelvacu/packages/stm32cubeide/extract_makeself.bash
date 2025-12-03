function extract_makeself_from_command() {
  declare targetDir="$1"
  shift
  declare secondLine
  secondLine="$("$@" | head -n 2 | tail -n 1)"
  if [[ $secondLine != "# This script was generated using Makeself 2.3.0" ]]; then
    echo "Unexpected Makeself version, don't know how to extract this" >&2
    exit 1
  fi

  function do_grep() {
    grep \
      --only-matching \
      --max-count=1 \
      --extended-regexp \
      --color=none \
      --text \
      "$@"
  }

  function infallible_head() {
    head "$@" || true
  }

  declare matches
  matches="$(
    "$@" |
      infallible_head --bytes=$((1000 * 1000)) |
      do_grep '`head -n [0-9]+ "\$0"'
  )"

  declare -i headerLineCount
  headerLineCount="$(printf '%s' "$matches" | sed -e 's/^.*head -n \([0-9]\+\) "$0".*$/\1/')"

  declare -i offset
  offset="$("$@" | head --lines=$headerLineCount | wc --bytes)"

  declare md5_def
  md5_def="$("$@" | infallible_head --bytes=$((1000 * 1000)) | do_grep --line-regexp 'MD5="[0-9a-fA-F ]+"')"
  declare MD5
  eval "$md5_def"

  "$@" | tail --bytes=+$((offset + 1)) | tee >(md5sum - | cut -b-32 >md5sum.txt) | tar -xvf - -C "$targetDir"
  declare computed_md5
  computed_md5="$(cat md5sum.txt)"
  if [[ $computed_md5 != "$MD5" ]]; then
    echo "Error: checksum failure, expected $MD5 but got $computed_md5" >&2
    exit 1
  fi
}
