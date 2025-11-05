{
  data,
  config,
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
    settings.hostPubkey = data.node.${config.networking.hostName}.ssh_key;
    secrets = {
      wg-azasos = {
        file = self + "/sec/wg-azasos.age";
        owner = "systemd-network";
        group = "root";
        mode = "400";
      };
      shadow-tls-relay = {
        file = self + "/sec/shadow-tls-relay.age";
      };
      hyst-osa-cli = {
        file = self + "/sec/hyst-cli.age";
        cleanPlaceholder = true;
        insert = {
          "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
            content = "172.234.92.148";
          };
        };
      };
      hyst-yi-cli = {
        file = self + "/sec/hyst-cli.age";
        cleanPlaceholder = true;
        insert = {
          "f3c4e59bfb78c6a26564724aaadda3ac3250d73ee903b17e3803785335bd082c" = {
            content = "8.210.47.13";
          };
        };
      };
    };
  };
}
