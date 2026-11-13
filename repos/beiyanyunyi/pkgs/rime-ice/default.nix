{
  lib,
  rime-ice,
  fetchFromGitHub,
}:
let
  source = lib.importJSON ./source.json;
in
rime-ice.overrideAttrs {
  version = source.rev;
  src = fetchFromGitHub {
    inherit (source) owner repo rev;
    hash = source.narHash;
  };
}
