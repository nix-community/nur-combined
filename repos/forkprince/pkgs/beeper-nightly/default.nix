{
  fetchurl,
  beeper,
  ...
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  inherit (info) version;
  src = fetchurl {inherit (info.src) url hash;};
in
  beeper.overrideAttrs (old: rec {
    pname = "beeper-nightly";
    name = "${pname}-${version}";

    inherit version src;
  })
