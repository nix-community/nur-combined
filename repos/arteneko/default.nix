{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  dolltags = pkgs.callPackage ./pkgs/dolltags {};
  dolltags-pre = pkgs.callPackage ./pkgs/dolltags/pre.nix {};

  todo-imap-to-html = pkgs.callPackage ./pkgs/todo-imap-to-html.nix {};
}
