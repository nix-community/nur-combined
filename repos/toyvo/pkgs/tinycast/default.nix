{
  pkgs,
  ...
}:
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
in
{
  tinycast = pkgs.tinycast.overrideAttrs {
    version = versions.stable.version;
    src = pkgs.fetchurl {
      url = "https://github.com/abue-ammar/tinycast/releases/download/v${versions.stable.version}/Tinycast-${versions.stable.version}.dmg";
      hash = versions.stable.hash;
    };
  };
  tinycast-beta = pkgs.tinycast.overrideAttrs {
    version = versions.beta.version;
    src = pkgs.fetchurl {
      url = "https://github.com/abue-ammar/tinycast/releases/download/v${versions.beta.version}/Tinycast-${versions.beta.version}.dmg";
      hash = versions.beta.hash;
    };
  };
}
