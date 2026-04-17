{
  flake.modules.nixos.ncps =
    { config, ... }:
    {
      vaultix.secrets.ncps = {
        owner = "ncps";
        mode = "400";
      };
      systemd.services.ncps = {
        requires = [ "seaweedfs.service" ];
        serviceConfig.EnvironmentFile = config.vaultix.secrets.ncps.path;
      };
      services.ncps = {
        enable = true;
        cache = {
          hostName = "cache.nyaw.xyz";
          maxSize = "200G";
          lru.schedule = "0 2 * * *";
          databaseURL = "postgresql://ncps@localhost:5432/ncps?sslmode=disable";
          storage.s3 = {
            bucket = "ncps";
            endpoint = "https://s3.nyaw.xyz";
            region = "ap-east-1";
            forcePathStyle = true;
          };
          upstream = {
            urls = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://devenv.cachix.org"
            ];
            publicKeys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
          };
        };
        server.addr = "[fdcc::3]:8501";
      };
    };
}
