{runCommandCC}:
runCommandCC "gethome" {meta.mainProgram = "gethome";} ''
  mkdir -p $out/bin
  cc -O2 -o $out/bin/gethome ${./gethome.c}
''
