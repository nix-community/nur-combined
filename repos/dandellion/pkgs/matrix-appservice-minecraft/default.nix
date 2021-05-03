{ pkgs, mkYarnPackage, fetchFromGitHub, nodejs-12_x, nodePackages, python3, pkgconfig, vips }:
let
  nodejs = nodejs-12_x;
  nodeHeaders = pkgs.fetchurl {
    url = "https://nodejs.org/download/release/v${nodejs.version}/node-v${nodejs.version}-headers.tar.gz";
    sha256 = "12415ss4fxxafp3w8rxp2jbb16y0d7f01b7wv72nmy3cwiqxqkhn";
  };
in
mkYarnPackage {
  pname = "matrix-appservice-minecraft-dev-";
  version = "2.4.4";
  
  src = fetchFromGitHub {
    owner = "dylhack";
    repo = "matrix-appservice-minecraft";
    rev = "03aaa8c9eb05f55328dfa44af17e115d7bf3de97";
    sha256 = "1l9xlv301kmn37ycs2gp1kvjpyvymx8k86c1r7gbvpbg8832j009";
  };

  buildPhase = ''
    yarn run build
  '';

  preInstall = ''
    sed -i '1i#!${nodejs}/bin/node' deps/matrix-appservice-minecraft/dist/src/app.js
    chmod -R +x deps/matrix-appservice-minecraft/dist
    mkdir -p $out
    ls deps/matrix-appservice-minecraft
    find . -name '*better_sqlite3.node*'
    #cp -r node_modules deps/matrix-appservice-minecraft/dist/src/node_modules
    #cp -r deps/matrix-appservice-minecraft/dist/src $out/src
  '';

  pkgConfig.better_sqlite3 = {
    buildInputs = [ nodePackages.node-gyp python3 pkgconfig vips ];
    postInstall = ''
      node-gyp --nodedir=${nodeHeaders} rebuild
    '';
  };
 
  #postInstall = ''
  #  node scripts/build.js --tarball=${nodeHeaders}
  #'';

  meta = {
    broken = true;
  };

}
