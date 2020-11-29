{ stdenv, pkgs, fetchFromGitHub, nodejs, nodePackages, pkg-config, cairo, pango, libpng, libjpeg, giflib, librsvg, makeWrapper, callPackage }:

let
  src = fetchFromGitHub {
    owner = "matrix-discord";
    repo = "mx-puppet-discord";
    rev = "47336e183ba832aeb0be6109576d2848b7794a1e";
    sha256 = "06vhjz3xsmhkv5hxf97kfjni0fxrpcp10q6lan56hpj2n7511sxz";
  };

  nodeComposition = callPackage ./node-packages.nix { };

  package = nodeComposition.shell.override {
    inherit src;

    buildInputs = [ cairo pango libpng libjpeg giflib librsvg ];
    nativeBuildInputs = [ nodePackages.node-pre-gyp nodePackages.node-gyp pkg-config ];
  };
in stdenv.mkDerivation rec {
  pname = "mx-puppet-discord";
  version = "2020-11-14";
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

  meta = with stdenv.lib; {
    platforms = platforms.linux;
  };
}
