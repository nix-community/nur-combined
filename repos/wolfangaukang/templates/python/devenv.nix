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
    ty
  ];
  languages = {
    nix.enable = true;
    python = {
      enable = true;
      lsp = {
        enable = true;
        package = ruff;
      };
      venv.enable = true;
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
