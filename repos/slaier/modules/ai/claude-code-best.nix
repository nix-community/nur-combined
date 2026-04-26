{ stdenv
, bun
, fetchurl
, makeWrapper
, ...
}:
stdenv.mkDerivation (final: {
  pname = "claude-code-best";
  version = "1.1.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/claude-code-best/-/claude-code-best-${final.version}.tgz";
    sha256 = "sha256-XzHhVcv51ASZ2n4auHVxdRArpsr6Gu3AVg77WYBtv3U=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/libexec/ccb
    cp dist/* $out/libexec/ccb
    makeWrapper ${bun}/bin/bun $out/bin/ccb \
      --add-flags "$out/libexec/ccb/cli.js"
  '';
})
