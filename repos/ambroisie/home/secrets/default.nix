{ lib, ... }:

with lib;
let
  throwOnCanary =
    let
      canaryHash = builtins.hashFile "sha256" ./canary;
      expectedHash =
        "9df8c065663197b5a1095122d48e140d3677d860343256abd5ab6e4fb4c696ab";
    in
    if canaryHash != expectedHash
    then throw "Secrets are not readable. Have you run `git-crypt unlock`?"
    else id;
in
throwOnCanary {
  options.my.secrets = mkOption {
    type =
      let
        valueType = with types; oneOf [
          int
          str
          (attrsOf valueType)
        ];
      in
      valueType;
  };

  config.my.secrets = {
    # Home-manager secrets go here
  };
}
