{
  lib,
  patchelf,
  fetchFromGitHub,
  autoreconfHook,
}:
let
  source = lib.importJSON ./source.json;
in
patchelf.overrideAttrs (old: {
  inherit (source) version;
  # LOAD segment fix: https://github.com/NixOS/patchelf/pull/672
  src = fetchFromGitHub {
    inherit (source) owner repo rev;
    hash = source.narHash;
  };
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ autoreconfHook ];
})
