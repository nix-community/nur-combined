{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
}:

stdenv.mkDerivation {
  pname = "xpilot-plugin";
  version = "4.0.0-beta.9";

  src = fetchurl {
    url = "https://xpilot.app/downloads/artifacts/4.0.0-beta.9/Plugin-linux.zip";
    hash = "sha256-Mkgaccompl4ivU3zRSMVKqSFkqW4014aRicAcdt7Yj8=";
    name = "xpilot-plugin-4.0.0-beta.9.zip";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  # The archive contains a single top-level `xPilot/` directory holding
  # `lin_x64/xPilot.xpl` and the plugin `Resources/`.
  unpackPhase = ''
    runHook preUnpack
    unzip "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r xPilot "$out/xPilot"
    runHook postInstall
  '';

  # Symlink (or copy) $out/xPilot into <X-Plane 12>/Resources/plugins/ so the
  # sim loads it as Resources/plugins/xPilot/lin_x64/xPilot.xpl.
  meta = {
    description = "xPilot X-Plane plugin for the VATSIM network";
    homepage = "https://xpilot.app";
    downloadPage = "https://xpilot.app";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
