{ lib, stdenv, fetchzip, nodejs_22, makeWrapper }:

let
  nodejs = nodejs_22;
  version = "18.0.9";
in
stdenv.mkDerivation {
  pname = "ccusage";
  inherit version;

  src = fetchzip {
    url = "https://registry.npmjs.org/ccusage/-/ccusage-${version}.tgz";
    sha256 = "sha256-3dIp3y1vHg2BI+aJZt2nDh8inAXgv8irvsQyOF7wnQc=";
    stripRoot = true;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/ccusage
    cp -r dist package.json $out/lib/ccusage/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/ccusage \
      --add-flags "$out/lib/ccusage/dist/index.js"
  '';

  meta = {
    description = "Claude Code usage analytics CLI tool";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage";
  };
}
