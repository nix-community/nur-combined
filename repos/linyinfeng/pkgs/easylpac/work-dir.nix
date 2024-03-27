{ runCommand, lpac_1 }:
runCommand "easylpac-work" { } ''
  mkdir -p "$out/lpac"
  ln -sv "${lpac_1}/bin/lpac" "$out/lpac"
  ln -sv "${lpac_1}/lib/lpac/"*.so "$out/lpac"
''
