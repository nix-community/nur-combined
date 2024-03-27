{ runCommand, lpac }:
runCommand "easylpac-work" { } ''
  mkdir -p "$out"
  ln -sv "${lpac}/bin/lpac" "$out/"
''
