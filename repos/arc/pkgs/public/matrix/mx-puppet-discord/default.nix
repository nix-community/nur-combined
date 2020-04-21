{ stdenv, pkgs, fetchFromGitHub, nodejs, makeWrapper }:

let
  src = fetchFromGitHub {
    owner = "matrix-discord";
    repo = "mx-puppet-discord";
    rev = "f2a2eb8013e3026212cecf79dcb8a7953233c74d";
    sha256 = "1zaya00qd1ccbihxn32n6i91bxsp3i5c77vh541xgz9299234fj0";
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
  version = "2020-04-10";
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
