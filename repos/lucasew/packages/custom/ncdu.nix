{ ncdu, writeShellScriptBin }:
writeShellScriptBin "ncdu" ''
  ${ncdu}/bin/ncdu --confirm-quit -x "$@"
''
