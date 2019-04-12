{ lib, pkgs }: { licenseAccepted ? false, platforms, buildTools }:

let
  androidsdk = import ./default.nix { inherit lib; inherit (pkgs) callPackage; };
  licenses = {
    android-sdk-license = "d56f5187479451eabf01fb78af6dfcb131a6481e";
  };
in if licenseAccepted then
  pkgs.buildEnv {
    name = "android-sdk-environment";
    paths = with androidsdk; [ tools platformTools ]
      ++ (map (p: builtins.getAttr "platform${toString p}" androidsdk) platforms)
      ++ (map (bt: builtins.getAttr "buildTools${toString bt}" androidsdk) buildTools);

    postBuild = ''
      mkdir -p $out/licenses
      ${lib.concatMapStrings (a: ''
        echo ${licenses.${a}} > $out/licenses/${a}
      '') (lib.attrNames licenses)}
    '';

    meta = {
      license = lib.licenses.unfree;
    };
  }
else throw "You must accept the android licenses. Pass licenseAccepted = true."
