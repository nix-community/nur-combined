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
  vaultix = {
    settings.hostPubkey = data.keys.azasosHostPubKey;
    secrets =
      {
        wga = {
          file = self + "/sec/wga.age";
          owner = "systemd-network";
          group = "root";
          mode = "400";
        };

        hyst-us-cli = {
          file = self + "/sec/hyst-us-cli.age";
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-us-cli.yaml";
        };
        shadow-tls-relay = {
          file = self + "/sec/shadow-tls-relay.age";
        };
        hyst-osa-cli = {
          file = self + "/sec/hyst-osa-cli.age";
          mode = "640";
          owner = "root";
          group = "users";
          name = "hyst-osa-cli.yaml";
        };
        hyst-hk-cli = {
          file = self + "/sec/hyst-hk-cli.age";
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
                file = self + "/sec/hyst-${n}-cli.age";
                mode = "640";
                owner = "root";
                group = "users";
                name = "hyst-${n}-cli.yaml";
              }
            )
            [
              "osa"
              "us"
              "hk"
            ]
        )
      );
  };
}
