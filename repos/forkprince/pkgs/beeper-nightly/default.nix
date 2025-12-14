{
  fetchurl,
  beeper,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  src = fetchurl (lib.helper.getApi ver);
in
  beeper.overrideAttrs (old: rec {
    pname = "beeper-nightly";
    name = "${pname}-${version}";

    inherit (ver) version;
    inherit src;
  })
