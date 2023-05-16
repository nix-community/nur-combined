{ pkgs ? import <nixpkgs> { }, ... }:
let
  inherit (pkgs) symlinkJoin writeShellScriptBin;
in
symlinkJoin {
  name = "personal-utils";
  paths = [
    (writeShellScriptBin "todo" ''
      curl $(cat ~/.dotfiles/secrets/todo_endpoint.env) -d "$*"
    '')
  ];
}
