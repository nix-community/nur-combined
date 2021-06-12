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
    type = types.attrs;
  };

  config.my.secrets = {
    acme.key = fileContents ./acme/key.env;

    backup = {
      password = fileContents ./backup/password.txt;
      credentials = readFile ./backup/credentials.env;
    };

    drone = {
      gitea = readFile ./drone/gitea.env;
      secret = readFile ./drone/secret.env;
      ssh = {
        publicKey = readFile ./drone/ssh/key.pub;
        privateKey = readFile ./drone/ssh/key;
      };
    };

    lohr.secret = fileContents ./lohr/secret.txt;

    matrix = {
      mail = import ./matrix/mail.nix;
      secret = fileContents ./matrix/secret.txt;
    };

    miniflux.password = fileContents ./miniflux/password.txt;

    nextcloud.password = fileContents ./nextcloud/password.txt;

    podgrab.password = fileContents ./podgrab/password.txt;

    transmission.password = fileContents ./transmission/password.txt;

    users = {
      ambroisie.hashedPassword = fileContents ./users/ambroisie/password.txt;
      root.hashedPassword = fileContents ./users/root/password.txt;
    };

    wireguard = import ./wireguard { inherit lib; };
  };
}
