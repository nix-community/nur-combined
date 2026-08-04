{ pkgs, ... }:

{
  # Using gopass
  programs.password-store = {
    enable = true;
    package = pkgs.gopass;
  };
}
