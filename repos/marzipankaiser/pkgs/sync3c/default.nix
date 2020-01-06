{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildGoPackage ? pkgs.buildGoPackage
, ...
}:
with pkgs;
buildGoPackage rec {
  name = "sync3c-git-${version}";
  version = "e7b331b9a7f376298466bd45380b7ff11592a0f4";

  src = fetchFromGitHub {
    owner = "muesli";
    repo = "sync3c";
    rev = version;
    sha256 = "0hbr28q6293hx0zai4j647ci3a1h058bbb93k0avb4lnr74yn36w";
  };

  goPackagePath = "github.com/muesli/sync3c";

  goDeps = ./deps.nix;

  buildFlags = "--tags release";

  meta = with lib; {
    description = "A little tool to sync/download media from https://media.ccc.de";
    homepage = https://github.com/muesli/sync3c;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
