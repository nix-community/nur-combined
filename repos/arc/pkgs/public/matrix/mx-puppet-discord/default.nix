{ stdenv, fetchFromGitHub, pkgs, lib, nodejs-14_x, nodePackages, nodeEnv, pkg-config, libjpeg
, vips, pixman, cairo, pango
, fetchgit, fetchurl
}:

let
  nodejs = nodejs-14_x;
  src = fetchFromGitHub {
    owner = "NicolasDerumigny";
    repo = "mx-puppet-discord";
    rev = "376221474c2cfc655370503f4716b7e7307f75a7";
    sha256 = "02m4qd12mda081cna3mkjgbv387z0lrwvrfxqdllv29kfhn7ir6y";
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
  version = "2022-01-09";

  inherit src;

  nativeBuildInputs = [ nodePackages.node-pre-gyp pkg-config ];
  buildInputs = [ libjpeg vips pixman cairo pango ];

  postInstall = ''
    # Patch shebangs in node_modules, otherwise the webpack build fails with interpreter problems
    patchShebangs --build "$out/lib/node_modules/mx-puppet-discord/node_modules/"
    # compile Typescript sources
    npm run build

    # Make an executable to run the server
    mkdir -p $out/bin
    cat <<EOF > $out/bin/mx-puppet-discord
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/node_modules/mx-puppet-discord/build/index.js "\$@"
    EOF
    chmod +x $out/bin/mx-puppet-discord
  '';

  meta = with lib; {
    description = "A discord puppeting bridge for matrix";
    license = licenses.asl20;
    homepage = "https://github.com/matrix-discord/mx-puppet-discord";
    maintainers = with maintainers; [ expipiplus1 ];
    platforms = platforms.unix;
  };
}
