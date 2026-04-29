{ self, ... }:
let
  hostPrivKey = "/var/lib/ssh/ssh_host_ed25519_key";
in
{
  flake.modules.nixos."age/hastur" =
    { config, ... }:
    {
      vaultix = {
        settings.hostPubkey = self.data.node.${config.networking.hostName}.ssh_key;
        secrets = {
          id = {
            mode = "400";
            owner = config.identity.user;
          };
          sing = { };
          age = {
            mode = "400";
            owner = config.identity.user;
          };
          atuin = {
            owner = config.identity.user;
            mode = "400";
          };
          atuin_key = {
            owner = config.identity.user;
            mode = "400";
          };
          sing-server = { };
          id_sk = {
            owner = config.identity.user;
            mode = "400";
          };
        };
      };
      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
    };
  flake.modules.nixos."age/eihort" =
    { config, ... }:
    {
      vaultix = {
        settings.hostPubkey = self.data.node.${config.networking.hostName}.ssh_key;
        secrets = {
          nuan = { };
          cfd = { };
          tg-session = {
            mode = "640";
            owner = "root";
            group = "root";
            name = "tg-session";
          };
          sing = { };
          tgexp = { };
          tg-env = {
            mode = "640";
            owner = "root";
            group = "root";
            name = "tg-env";
          };
          pocketid = {
            mode = "400";
            owner = config.services.pocket-id.user;
          };

          age = {
            mode = "400";
            owner = config.identity.user;
          };
          atuin = {
            owner = config.identity.user;
            mode = "400";
          };
          atuin_key = {
            owner = config.identity.user;
            mode = "400";
          };
        };
      };
      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
    };
  flake.modules.nixos."age/abhoth" =
    { config, ... }:
    {

      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
      vaultix = {
        settings.hostPubkey = config.data.node.${config.networking.hostName}.ssh_key;

        secrets = {
          # postfix-sasl = { };
          stalwart = { };
          xray = { };
        };
      };
    };
  flake.modules.nixos."age/yidhra" =
    { config, ... }:
    {

      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
      vaultix = {
        settings.hostPubkey = config.data.node.${config.networking.hostName}.ssh_key;

        secrets = {
          # postfix-sasl = { };
          wg-yidhra = {
            owner = "systemd-network";
            group = "root";
            mode = "400";
          };

          wgy-warp = {
            owner = "systemd-network";
            group = "root";
            mode = "400";
          };
          subs = {
            mode = "740";
            owner = config.identity.user;
            group = "root";
            name = "subs.ts";
          };

          xray = { };
        };
      };
    };
  flake.modules.nixos."age/kaambl" =
    { config, ... }:
    {

      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
      vaultix = {
        settings.hostPubkey = config.data.node.${config.networking.hostName}.ssh_key;

        secrets = {
          # postfix-sasl = { };
          sing = { };
          id = {
            # file = ../../sec/id.age;
            mode = "400";
            owner = config.identity.user;
            group = "users";
          };
          age = {
            mode = "400";
            owner = config.identity.user;
          };
          garage = { };
          atuin_key = {
            owner = config.identity.user;
            mode = "400";
          };
          atuin = {
            owner = config.identity.user;
            mode = "400";
          };
        };
      };
    };
  flake.modules.nixos."age/uubboo" =
    { config, ... }:
    {

      services.openssh.hostKeys = [
        {
          path = hostPrivKey;
          type = "ed25519";
        }
      ];
      vaultix = {
        settings.hostPubkey = config.data.node.${config.networking.hostName}.ssh_key;

        secrets = {
          sing = { };
        };
      };
    };
}
