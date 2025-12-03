{
  pkgs,
  ...
}:

let
  inherit (pkgs) gorin ruff ty;

in
{
  packages = [
    gorin
    ruff
    ty
  ];
  languages = {
    nix.enable = true;
    python = {
      enable = true;
      uv = {
        enable = true;
        sync = {
          packages = true;
          groups = [ "dev" ];
        };
      };
    };
  };
}
