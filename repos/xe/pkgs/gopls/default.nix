{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  out = buildGoPackage {
    name = "gopls-git";
    goPackagePath = "golang.org/x/tools";
    src = fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "cfa8b22178d2faeacea202c63787cc6193a51a8c";
      sha256 = "1dayvnib80cci1536qgxsqda3wp3c6bv8wskvdlvxzk280qjqixg";
    };
    goDeps = ./deps.nix;
    subPackages = [ "gopls" ];
  };
in out
