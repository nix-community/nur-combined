{global, pkgs, ...}:
let
  inherit (global) username;
in {
  nix = {
    settings = {
      trusted-users = [username "@wheel"];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
