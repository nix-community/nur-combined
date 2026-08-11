/*
binary release of pandoc, because fuck haskell in nixpkgs.

i tried cabal2nix, but i must call it manually for every cabal package:

  cabal2nix https://github.com/kazu-yamamoto/crypton-connection/raw/master/crypton-connection.cabal >crypton-connection.nix
  cabal2nix https://github.com/kazu-yamamoto/crypton-certificate/raw/master/x509/crypton-x509.cabal >crypton-x509.nix
  cabal2nix https://github.com/jgm/pandoc/raw/main/pandoc.cabal >pandoc.nix

ideally, i want something automatic like npmlock2nix,
to convert a lockfile to a nix expression.

https://github.com/jgm/pandoc/releases
https://nixos.wiki/wiki/Haskell
https://haskell4nix.readthedocs.io/nixpkgs-developers-guide.html
https://github.com/NixOS/nixpkgs/issues/221165 # Update request: pandoc 2.19.2 → 3.1.1
*/

/*
$ nix-shell -p pkgs.haskellPackages.pandoc_3_1_2
Configuring pandoc-3.1.2...

Setup: Encountered missing or private dependencies:
doctemplates >=0.11 && <0.12,
gridtables >=0.1 && <0.2,
jira-wiki-markup >=1.5.1 && <1.6,
mime-types >=0.1.1 && <0.2,
pandoc-types >=1.23 && <1.24,
texmath >=0.12.7 && <0.13

error: builder for '/nix/store/5nz0s58qvisys5ga197fxz97ql47ny7q-pandoc-3.1.2.drv' failed with exit code 1;
*/

{ lib
, stdenv
, fetchurl
, pandoc
}:

stdenv.mkDerivation rec {
  pname = "pandoc-bin";
  version = "3.1.8";
  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
    sha256 = "sha256-wHkjplMhtCRmWGNe3OUXrmV4q7ZTlr/5FP7vN7xIeEs=";
  };
  installPhase = ''
    cd ..
    mv $sourceRoot $out
  '';
  meta = pandoc.meta;
}
