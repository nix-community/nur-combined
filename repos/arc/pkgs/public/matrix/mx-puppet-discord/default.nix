{ stdenv, lib, pkgs, fetchFromGitHub, nodejs, nodePackages, pkg-config, cairo, pango, libpng, libjpeg, giflib, librsvg, makeWrapper, callPackage }:

let
  src = fetchFromGitHub {
    owner = "matrix-discord";
    repo = "mx-puppet-discord";
    rev = "c17384a6a12a42a528e0b1259f8073e8db89b8f4";
    sha256 = "1yczhfpa4qzvijcpgc2pr10s009qb6jwlfwpcbb17g2wsx6zj0c2";
  };

  nodeComposition = callPackage ./node-packages.nix { };

  package = nodeComposition.shell.override {
    inherit src;

    buildInputs = [ cairo pango libpng libjpeg giflib librsvg ];
    nativeBuildInputs = [ nodePackages.node-pre-gyp nodePackages.node-gyp pkg-config ];
  };
in stdenv.mkDerivation rec {
  pname = "mx-puppet-discord";
  version = "2021-01-21";
  inherit src;

  buildInputs = [ nodejs makeWrapper ];

  inherit (package) nodeDependencies;

  buildPhase = ''
    ln -s $nodeDependencies/lib/node_modules
    npm run-script build
    sed -i '1i #!${nodejs}/bin/node\n' build/index.js
  '';

  installPhase = ''
    cp -r . $out
    mkdir -p $out/bin
    chmod a+x $out/build/index.js
    makeWrapper $out/build/index.js $out/bin/${pname}
  '';

  meta = with lib; {
    platforms = platforms.linux;
  };
}
