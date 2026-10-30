{ self, ... }:
let
  hostPrivKey = "/var/lib/ssh/ssh_host_ed25519_key";
  # A content-addressed public PEM avoids restarting the Server after unrelated
  # flake-source changes. This expression never reads the private key.
  realmSpireCA = builtins.toFile "realm-spire-upstream-ca.pem" (
    builtins.readFile ../pki/realm-spire/upstream-ca.pem
  );
in
{
  flake.modules.nixos."age/hastur" =
    { config, ... }:
    {
      vaultix = {
        settings.hostPubkey = self.data.node.${config.networking.hostName}.ssh_key;
        settings.flake = self;
        secrets = {
          id = {
            mode = "400";
            owner = config.identity.user;
          };
          sing = { };
          xray-cli = { };
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
      realm.spire.server.upstream = {
        enable = true;
        certificate = realmSpireCA;
        bundle = realmSpireCA;
        keyFile = config.vaultix.secrets.realm-spire-upstream-key.path;
      };
      systemd.services.spire-server = {
        requires = [ "vaultix-activate.service" ];
        after = [ "vaultix-activate.service" ];
        restartTriggers = [ config.vaultix.secrets.realm-spire-upstream-key.file ];
      };
      vaultix = {
        settings.hostPubkey = self.data.node.${config.networking.hostName}.ssh_key;
        settings.flake = self;
        secrets = {
          realm-spire-upstream-key = {
            owner = "root";
            group = "root";
            mode = "0400";
          };
          nuan = { };
          cfd = { };
          monitou = { };
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

          # xray-cli = { };
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
        settings.flake = self;

        secrets = {
          # postfix-sasl = { };
          stalwart = { };
          xray = { };
          hy = { };
        };
      };
    };
  flake.modules.nixos."age/nodens" =
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
        settings.flake = self;

        secrets = {
          xray = { };
          hy = { };
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
        settings.flake = self;

        secrets = {
          # postfix-sasl = { };
          wg-yidhra = {
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
          hy = { };
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
        settings.flake = self;

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
        settings.flake = self;

        secrets = {
          sing = { };
          # xray-cli = { };
        };
      };
    };
  flake.modules.nixos."age/azasos" =
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
        settings.flake = self;
        secrets = {
          xray = { };
          subs = {
            mode = "740";
            owner = config.identity.user;
            group = "root";
            name = "subs.ts";
          };
          hy = { };
        };
      };
    };
}
