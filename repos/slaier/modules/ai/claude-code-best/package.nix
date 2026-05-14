{ stdenv
, bun
, fetchurl
, makeWrapper
, ...
}:
stdenv.mkDerivation (final: {
  pname = "claude-code-best";
  version = "2.4.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/claude-code-best/-/claude-code-best-${final.version}.tgz";
    sha256 = "sha256-M7juSqPoPULL7lOtU2SNC43CUYElMkhROxQ9eu2LalA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/libexec/ccb
    cp -r dist/* $out/libexec/ccb
    makeWrapper ${bun}/bin/bun $out/bin/ccb \
      --add-flags "$out/libexec/ccb/cli.js"
  '';
})
