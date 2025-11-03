{ pkgs, ... }:

{
  # https://github.com/NixOS/nixpkgs/issues/323016
  # https://github.com/NixOS/nixpkgs/issues/323083
  environment.systemPackages = [
    pkgs.lua5_4
    pkgs.luaformatter
    pkgs.lua-language-server

    pkgs.lua5_4.pkgs.fennel
  ];

  boot.binfmt.registrations.lua = {
    recognitionType = "extension";
    magicOrExtension = "lua";
    interpreter = pkgs.lua5_4.interpreter;
  };
}
