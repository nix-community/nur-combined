{ stdenv, pkgs, fetchFromGitHub, nodejs, makeWrapper }:

let
  src = fetchFromGitHub {
    owner = "matrix-discord";
    repo = "mx-puppet-discord";
    rev = "28e7da75136771139b3ee3b5fdac92949cc4d561";
    sha256 = "190jldvka1ym1crwcgaq4hcsh40906rwiw5dljpxvvs1hvj5p1xy";
  };

  nodePackages = import ./node-composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    inherit nodejs;
  };

  shell = nodePackages.shell.override {
    inherit src;
  };
in stdenv.mkDerivation rec {
  pname = "mx-puppet-discord";
  version = "2020-09-05";
  inherit src;

  buildInputs = [ nodejs makeWrapper ];

  buildPhase = ''
    ln -s ${shell.nodeDependencies}/lib/node_modules
    npm run-script build
    sed -i '1i #!${nodejs}/bin/node\n' build/index.js
  '';

  installPhase = ''
    cp -r . $out
    mkdir -p $out/bin
    chmod a+x $out/build/index.js
    makeWrapper $out/build/index.js $out/bin/${pname}
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
  };
}
