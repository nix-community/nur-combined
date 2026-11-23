{
  lib,
  pkgs,
  nixpak,
}:

let
  mkNixPak = nixpak.lib.nixpak {
    inherit lib pkgs;
  };

  # extraModules are merged as NixPak modules; strip the argument before eval.
  mkSandboxedApp =
    {
      extraModules ? [ ],
      ...
    }@args:
    mkNixPak (
      lib.removeAttrs args [ "extraModules" ]
      // {
        config = {
          imports = [
            ./common.nix
            args.config
          ]
          ++ extraModules;
        };
      }
    );

in
{
  nixpak = mkSandboxedApp;

  fonts = import ./fonts.nix {
    inherit pkgs;
  };
}
