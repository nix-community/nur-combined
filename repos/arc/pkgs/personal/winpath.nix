{ writeShellScriptBin, gnused }: writeShellScriptBin "winpath" ''
  if [[ $# -gt 0 ]]; then
      printf %s "$*"
  else
      cat
  fi | ${gnused}/bin/sed -e 's|\\|/|g' -e 's|^\([A-Za-z]\)\:/\(.*\)|/mnt/\L\1\E/\2|'
''
