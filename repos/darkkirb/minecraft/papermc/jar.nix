{fetchurl}: let
  versionInfo = builtins.fromJSON (builtins.readFile ./paper.json);
in
  fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/${versionInfo.version}/builds/${toString versionInfo.build}/downloads/${versionInfo.name}";
    inherit (versionInfo) sha256;
  }
