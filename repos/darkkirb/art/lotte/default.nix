{
  stdenv,
  fetchgit,
  lib,
}: let
  srcInfo = builtins.fromJSON (builtins.readFile ./source.json);
  src = fetchgit {
    inherit (srcInfo) url rev sha256 fetchLFS fetchSubmodules deepClone leaveDotGit;
  };
in
  src.overrideAttrs (_: rec {
    name = "${pname}-${version}";
    pname = "lotte-art";
    version = srcInfo.date;
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://git.chir.rs/darkkirb/lotte-art"
      "art/lotte/source.json"
      "--fetch-lfs"
    ];
    meta = {
      description = "Art I commissioned (mostly)";
      license = lib.licenses.cc-by-nc-sa-40;
    };
  })
