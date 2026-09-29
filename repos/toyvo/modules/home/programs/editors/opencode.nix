{
  config,
  lib,
  pkgs,
  stablePkgs,
  ...
}:

{
  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode.settings = {
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
        # Ghostex registers its session hook plugin (./plugins/ghostex-session.js)
        # in this file at runtime. Pre-seed it so home-manager resets stay
        # consistent with what Ghostex expects (see below).
        "./plugins/ghostex-session.js"
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
          command = [ (lib.getExe stablePkgs.mcp-nixos) ];
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

    # Ghostex merges its session hook plugin registration into opencode.json
    # at runtime, but home-manager installs the file as a read-only store
    # symlink, so the write fails with EACCES and hook install/status break
    # ("Agent hook install failed"). Keep the file managed for content, but
    # install a writable copy on every switch and let home-manager replace it
    # (lossless: the Ghostex plugin entry above is part of the managed content).
    xdg.configFile."opencode/opencode.json".force = true;

    home.activation.makeOpencodeJsonWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      opencodeJson="$HOME/.config/opencode/opencode.json"
      if [ -L "$opencodeJson" ]; then
        run cp --remove-destination "$(readlink "$opencodeJson")" "$opencodeJson"
        run chmod u+w "$opencodeJson"
      fi
    '';
  };
}
