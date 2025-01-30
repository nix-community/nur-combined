{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  dolltags = pkgs.callPackage ./pkgs/dolltags {};
  dolltags-dev = pkgs.callPackage ./pkgs/dolltags/dev.nix {};

  todo-imap-to-html = pkgs.callPackage ./pkgs/todo-imap-to-html.nix {};
}
