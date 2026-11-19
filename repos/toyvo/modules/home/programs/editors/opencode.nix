{
  config,
  lib,
  pkgs,
  stablePkgs,
  ...
}:

{
  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode.package = pkgs.opencode.overrideAttrs (old: {
      # NOTE 2026-11-05 (updated 2026-11-19): nixpkgs opencode's node_modules
      # fixed-output hash is stale (upstream registry drift). Pinned hashes:
      # 2.2.5 shipped sha256-xfOVcw1+waLVNhFDwzOtzxrUSQEogvn88YomydOlhwc=,
      # CI reported sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=;
      # 2.3.0 reports sha256-zaRjXditlZ8C741SeBv8n0ChlfYFrD/l0fKcuo2dxrI=.
      # Revert once nixpkgs ships a fixed hash or version bump. If it keeps
      # drifting, drop the nixpkgs build and install opencode via upstream
      # script instead.
      node_modules = old.node_modules.overrideAttrs {
        outputHash = "sha256-zaRjXditlZ8C741SeBv8n0ChlfYFrD/l0fKcuo2dxrI=";
      };
    });
    programs.opencode.settings = {
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
      ];

      permission = {
        external_directory = {
          "${config.home.homeDirectory}/.config/opencode/**" = "allow";
          "${config.home.homeDirectory}/.local/share/opencode/**" = "allow";
          "${config.home.homeDirectory}/.cargo/**" = "allow";
          "${config.home.homeDirectory}/Code/**" = "allow";
          "${config.home.homeDirectory}/Clone/**" = "allow";
          "${config.home.homeDirectory}/nixcfg/**" = "allow";
          "/nix/**" = "allow";
          "/tmp/**" = "allow";
        };
      };

      mcp = {
        nixos = {
          command = [ (lib.getExe pkgs.mcp-nixos) ];
          enabled = true;
          type = "local";
        };
        chrome-devtools = {
          command = [
            "npx"
            "-y"
            "chrome-devtools-mcp@latest"
          ];
          enabled = true;
          type = "local";
        };
      };
    };
  };
}
