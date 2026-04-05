unpackCmdHooks+=(_try7zz)

_try7zz() {
  7zz x $curSrc -osource
  while true; do
    files=(source/*)
    if [[ ! ${#files[@]} -eq 1 || ! -d "${files[0]}" ]]; then
      break
    fi
    mv "${files[0]}" new-source
    rm -r source
    mv new-source source
  done
}
