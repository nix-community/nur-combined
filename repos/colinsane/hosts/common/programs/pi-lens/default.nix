{ ... }:
{
  sane.programs.pi-lens = {
    packageUnwrapped = null;  # installed directly by pi.
    suggestedPrograms = [ "nixd" ];

    fs.".pi-lens/lsp.json".symlink.text = builtins.toJSON {
      servers = {
        nixd = {
          name = "nixd";
          extensions = [ ".nix" ];
          command = "nixd";
          args = [ ];
          rootMarkers = [
            "default.nix"
            "flake.nix"
          ];
        };
      };
    };

    fs.".pi-lens/config.json".symlink.text = builtins.toJSON {
      format = {
        enabled = false;
      };
    };
  };
}
