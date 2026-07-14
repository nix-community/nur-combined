{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_22,
  mihomo,
}:

let
  pname = "xream-http-meta";
  version = "1.0.6";
  httpMetaBundle = fetchurl {
    url = "https://github.com/xream/http-meta/releases/download/${version}/http-meta.bundle.js";
    sha256 = "sha256-g4MuOAro54xKPPcurzVGl3ecSI9Md5cLA8tW6bgpbzI=";
  };
  tplYaml = fetchurl {
    url = "https://github.com/xream/http-meta/releases/download/${version}/tpl.yaml";
    sha256 = "sha256-bz7PGZrppQFLAJCkaw38FsZOT8RTUIgHJqVuy2Ut0Ww=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  srcs = [
    httpMetaBundle
    tplYaml
  ];

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/http-meta
    cp ${httpMetaBundle} $out/lib/http-meta/http-meta.bundle.js
    cp ${tplYaml} $out/lib/http-meta/tpl.yaml

    ln -s ${mihomo}/bin/mihomo $out/lib/http-meta/http-meta

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    makeWrapper ${nodejs_22}/bin/node $out/bin/http-meta \
      --set-default META_FOLDER $out/lib/http-meta/ \
      --add-flags "$out/lib/http-meta/http-meta.bundle.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "http-meta bundle (node) + tpl.yaml + mihomo from nixpkgs in META_FOLDER";
    platforms = platforms.linux;
    license = licenses.gpl3Only;
    mainProgram = "http-meta";
  };
}
