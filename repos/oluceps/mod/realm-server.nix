{ self, ... }:
{
  flake.modules.nixos.realm-server =
    {
      pkgs,
      config,
      ...
    }:
    {
      realm.spire.server.upstream = {
        enable = true;
        certificate = self.fn.${pkgs.stdenv.hostPlatform.system}.pki.realm-spire_file;
        bundle = self.fn.${pkgs.stdenv.hostPlatform.system}.pki.realm-spire_file;
        keyFile = config.vaultix.secrets.realm-spire-upstream-key.path;
      };
      systemd.services.spire-server = {
        requires = [ "vaultix-activate.service" ];
        after = [ "vaultix-activate.service" ];
        restartTriggers = [ config.vaultix.secrets.realm-spire-upstream-key.file ];
      };
      vaultix.secrets.realm-spire-upstream-key = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
}
