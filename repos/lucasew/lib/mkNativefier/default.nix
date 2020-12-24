pkgs: {
    name, 
    url, 
    icon ? null,
    electron ? pkgs.electron, 
    props ? {}
  }:
let
  nativefier = (import ./package_data {pkgs = pkgs;}).nativefier;
  processedProps = {
    name = name;
    targetUrl = url;
    badge = false;
    showMenuBar = false;
  } // props;
  writtenProps = pkgs.writeText "nativefier.json" (builtins.toJSON processedProps);
  drv = pkgs.stdenv.mkDerivation {
    name = name;
    dontUnpack = true;
    installPhase = ''
      export OUT_DIR=$out/share/${name}-nativefier
      mkdir $OUT_DIR -p
      cp -r ${nativefier}/lib/node_modules/nativefier/app/* $OUT_DIR
      rm $OUT_DIR/nativefier.json
      cat ${writtenProps} > $OUT_DIR/nativefier.json
    '';
  };
  binary = pkgs.writeShellScriptBin name ''
    ${electron}/bin/electron ${drv}/share/${name}-nativefier/lib/main.js
  '';
  desktop = pkgs.makeDesktopItem {
    name = name;
    desktopName = "${name}";
    icon = icon;
    type = "Application";
    exec = "${binary}/bin/${name}";
  };
in pkgs.stdenv.mkDerivation {
  name = "nativefier-${name}-entrypoint";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out
    cp -r ${desktop}/* $out
    cp -r ${binary}/* $out
  '';
}
