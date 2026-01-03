{
  writeShellScript,
  genericBinWrapper,
  nvidia-offload,
}:
pkg:
let
  wrapper = writeShellScript "nvidia-offload" ''
    ${nvidia-offload}/bin/nvidia-offload "@EXECUTABLE@" "$@"
  '';
in
genericBinWrapper pkg wrapper
