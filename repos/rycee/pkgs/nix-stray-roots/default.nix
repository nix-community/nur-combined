{ gnugrep, writeShellScriptBin }:

writeShellScriptBin "nix-stray-roots" ''
  nix-store --gc --print-roots \
    | ${gnugrep}/bin/egrep -v '^(/proc|/nix/var|/run/\w+-system|\{memory|\{temp|.*/.cache/lorri)'
''
