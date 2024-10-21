{
  data,
  lib,
  self,
  ...
}:
let
  hostPrivKey = "/var/lib/ssh/ssh_host_ed25519_key";
in
{
  services.openssh.hostKeys = [
    {
      path = hostPrivKey;
      type = "ed25519";
    }
  ];
  age = {
    identityPaths = [ hostPrivKey ];
    rekey.hostPubkey = data.keys.azasosHostPubKey;
    secrets =
      {
        wga = {
          rekeyFile = ../../sec/wga.age;
          owner = "systemd-network";
          group = "root";
          mode = "400";
        };

        hyst-us-cli = {
          rekeyFile = ../sec/hyst-us-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us-cli.yaml";
        };
        hyst-la-cli = {
          rekeyFile = ../sec/hyst-la-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-la-cli.yaml";
        };
        hyst-hk-cli = {
          rekeyFile = ../sec/hyst-hk-cli.age;
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-hk-cli.yaml";
        };
      }
      // (
        let
          inherit (lib) listToAttrs nameValuePair;
        in
        listToAttrs (
          map
            (
              n:
              nameValuePair "hyst-${n}-cli" {
                rekeyFile = "${self}/sec/hyst-${n}-cli.age";
                mode = "640";
                owner = "root";
                group = "users";
                name = "hyst-${n}-cli.yaml";
              }
            )
            [
              "la"
              "us"
              "hk"
            ]
        )
      );
  };
}
