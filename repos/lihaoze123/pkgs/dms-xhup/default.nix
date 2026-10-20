{ lib, stdenvNoCC, fetchFromGitHub, writeShellApplication, python3, systemd, serviceArgs ? [ ] }:
let
  pin = lib.importJSON ./source.json;
  src = fetchFromGitHub { inherit (pin) owner repo rev hash; };
  backend = writeShellApplication {
    name = "dms-xhup-backend";
    runtimeInputs = [ (python3.withPackages (ps: [ ps.pyyaml ps.pypinyin ])) systemd ];
    text = ''
      exec python3 ${src}/backend/xhup_service.py ${lib.escapeShellArgs serviceArgs} "$@"
    '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "dms-xhup";
  inherit (pin) version;
  inherit src;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r plugin.json backend translations *.qml *.js "$out/"
    cat > "$out/config.js" <<'JS'
    .pragma library
    var command = ["${lib.getExe backend}"];
    JS
    runHook postInstall
  '';
  passthru = { inherit backend; };
  meta = {
    description = "DankMaterialShell plugin for Xiaohe Yinxing code lookup, word adding and root chart";
    homepage = "https://github.com/lihaoze123/dms-xhup";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
