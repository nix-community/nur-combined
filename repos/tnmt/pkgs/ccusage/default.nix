{ lib, stdenv, fetchzip, nodejs_22, makeWrapper, nix-update-script }:

let
  nodejs = nodejs_22;
  version = "19.0.3";
in
stdenv.mkDerivation {
  pname = "ccusage";
  inherit version;

  src = fetchzip {
    url = "https://registry.npmjs.org/ccusage/-/ccusage-${version}.tgz";
    sha256 = "sha256-9nIZhmt9h2pzEtCpKs4SJ+2T6I+w4lFcAnRGeXvbgxk=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Claude Code usage analytics CLI tool";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = lib.licenses.mit;
    mainProgram = "ccusage";
  };
}
