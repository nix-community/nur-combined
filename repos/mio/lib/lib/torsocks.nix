{
  writeShellScript,
  genericBinWrapper,
  torsocks,
}:
pkg:
let
  wrapper = writeShellScript "torsocks-wrapper" ''
    ${torsocks}/bin/torsocks "@EXECUTABLE@" "$@"
  '';
in
genericBinWrapper pkg wrapper
