{
  fetchurl,
  beeper,
  ...
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  inherit (info) version;
  src = fetchurl {inherit (info.src) url hash;};
in
  beeper.overrideAttrs {
    pname = "beeper-nightly";

    inherit version src;
  }
