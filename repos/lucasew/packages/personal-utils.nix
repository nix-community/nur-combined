{pkgs ? import <nixpkgs> {}, ...}:
pkgs.symlinkJoin {
  name = "personal-utils";
  paths = [
    (pkgs.writeShellScriptBin "todo" ''
      curl $(cat ~/.dotfiles/secrets/todo_endpoint.env) -d "$*"
    '')
  ];
}
