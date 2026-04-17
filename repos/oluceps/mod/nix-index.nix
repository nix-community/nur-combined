{
  flake.modules.nixos.nix-index =
    { pkgs, config, ... }:
    {
      systemd.user.services.nix-index = {
        environment = config.networking.proxy.envVars;
        script = ''
          FILE=index-x86_64-linux
          mkdir -p ~/.cache/nix-index
          cd ~/.cache/nix-index
          ${pkgs.curl}/bin/curl -LO https://github.com/Mic92/nix-index-database/releases/latest/download/$FILE
          mv -v $FILE files
        '';
        serviceConfig = {
          Restart = "on-failure";
          Type = "oneshot";
        };
        startAt = "weekly";
      };

    };
}
