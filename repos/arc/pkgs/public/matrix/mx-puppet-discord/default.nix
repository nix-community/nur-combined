{ stdenv, fetchFromGitLab, pkgs, lib, nodejs-18_x, nodeEnv, pkg-config, libjpeg
, vips, pixman, cairo, pango
, fetchgit, fetchurl
}:

let
  nodejs = nodejs-18_x;
  src = fetchFromGitLab {
    owner = "ruslang02";
    repo = "mx-puppet-discord";
    rev = "785d0a0f8def8c7a404d3ba7dea552e1e4cb55ce";
    sha256 = "sha256-WuAh2AGScxu1w1mlTAfaxGO2jUotoonrhLSxk2B75PI=";
  };

  myNodePackages = import ./node-packages.nix {
    inherit fetchurl stdenv lib fetchgit;
    nodeEnv = nodeEnv.override {
      inherit nodejs;
    };
    nix-gitignore = throw "nix-gitignore";
  };

in myNodePackages.package.override {
  pname = "mx-puppet-discord-develop";
  version = "2022-09-23";

  inherit src;

  nativeBuildInputs = [ nodejs.pkgs.node-pre-gyp pkg-config ];
  buildInputs = [ libjpeg vips pixman cairo pango ];

  postInstall = ''
    # Patch shebangs in node_modules, otherwise the webpack build fails with interpreter problems
    patchShebangs --build "$out/lib/node_modules/mx-puppet-discord/node_modules/"
    # compile Typescript sources
    patch -p1 < ${./typescript.patch}
    npm run build

    # Make an executable to run the server
    mkdir -p $out/bin
    cat <<EOF > $out/bin/mx-puppet-discord
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/node_modules/@mx-puppet/discord/build/index.js "\$@"
    EOF
    chmod +x $out/bin/mx-puppet-discord
  '';

  meta = with lib; {
    description = "A discord puppeting bridge for matrix";
    license = licenses.asl20;
    homepage = "https://gitlab.com/mx-puppet/mx-puppet-discord";
    platforms = platforms.unix;
  };
}
