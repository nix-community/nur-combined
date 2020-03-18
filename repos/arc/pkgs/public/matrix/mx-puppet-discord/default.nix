{ stdenv, pkgs, fetchFromGitHub, nodejs, makeWrapper }:

let
  src = fetchFromGitHub {
    owner = "matrix-discord";
    repo = "mx-puppet-discord";
    rev = "0cb054004253534f1df3bdae030043e14f9961c2";
    sha256 = "0f8q0x9hbxsfipjxmqr1ri85wjrgn90dybji8xfi2lr47bn2h6ky";
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
  version = "2020-03-04";
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
