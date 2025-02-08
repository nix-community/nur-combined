{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  dolltags = pkgs.callPackage ./pkgs/dolltags {};
  dolltags-dev = pkgs.callPackage ./pkgs/dolltags/dev.nix {};

  cap = pkgs.callPackage ./pkgs/cap.nix {};
  todo-imap-to-html = pkgs.callPackage ./pkgs/todo-imap-to-html.nix {};
}
