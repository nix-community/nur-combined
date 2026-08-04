{
  pkgs,
  ...
}:

let
  inherit (pkgs) gorin lldb;

in
{
  packages = [
    gorin
    lldb
  ];

  languages = {
    nix.enable = true;
    rust.enable = true;
  };
}
