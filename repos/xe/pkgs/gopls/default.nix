{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  out = buildGoPackage {
    name = "gopls-git";
    goPackagePath = "golang.org/x/tools";
    src = fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "44a64ad78b9b521790ab78240c17a3bc75b5eaa7";
      sha256 = "1lnr5pcagfzwk0r2jh49kfqivcim4rrigkijqy6fm86pm2f4bjyg";
    };
    goDeps = ./deps.nix;
    subPackages = [ "gopls" ];
  };
in out
