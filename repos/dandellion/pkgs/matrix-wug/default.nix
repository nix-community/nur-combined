{ mkYarnPackage, fetchFromGitHub, nodejs-10_x }:

mkYarnPackage {
  pname = "matrix-wug";
  version = "2.4.4";
  
  src = fetchFromGitHub {
    owner = "dali99";
    repo = "matrix-wug";
    rev = "2.4.4";
    sha256 = "0q0sv6dwqigd7gvdkrwxc4ygzmfl159c96iab5jk4bfjz4ard59f";
  };

  buildPhase = ''
    yarn run build
  '';

  preInstall = ''
    sed -i '1i#!/usr/bin/env node' deps/matrix-wug/build/index.js
    chmod +x deps/matrix-wug/build/index.js
    cp deps/matrix-wug/x2i/dictionaries/*.yaml deps/matrix-wug/build/x2i/dictionaries/
    #ln -s $out/bin/matrix-wug deps/matrix-wug/build/index.js
  '';
}
