{
  lib,
  stdenvNoCC,
  writeShellApplication,
  fetchurl,
  nodejs_22,
  mihomo,
}:

let
  httpMetaVersion = "1.0.6";
  httpMetaBundle = fetchurl {
    url = "https://github.com/xream/http-meta/releases/download/${httpMetaVersion}/http-meta.bundle.js";
    sha256 = "sha256-g4MuOAro54xKPPcurzVGl3ecSI9Md5cLA8tW6bgpbzI=";
  };
  tplYaml = fetchurl {
    url = "https://github.com/xream/http-meta/releases/download/${httpMetaVersion}/tpl.yaml";
    sha256 = "sha256-bz7PGZrppQFLAJCkaw38FsZOT8RTUIgHJqVuy2Ut0Ww=";
  };
  assets = stdenvNoCC.mkDerivation {
    name = "http-meta-assets";
    version = httpMetaVersion;
    srcs = [
      httpMetaBundle
      tplYaml
    ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/opt/app/http-meta
      cp ${httpMetaBundle} $out/opt/app/http-meta.bundle.js
      cp ${tplYaml} $out/opt/app/http-meta/tpl.yaml

      ln -s ${mihomo}/bin/mihomo $out/opt/app/http-meta/http-meta
    '';
  };
in
writeShellApplication {
  name = "sub-store-http-meta";

  text = ''
    APP_DIR="${assets}/opt/app"

    export META_FOLDER="$APP_DIR/http-meta"
    exec ${nodejs_22}/bin/node "$APP_DIR/http-meta.bundle.js"
  '';

  meta = with lib; {
    description = "http-meta bundle (node) + tpl.yaml + mihomo from nixpkgs in META_FOLDER";
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
    mainProgram = "http-meta";
  };
}
