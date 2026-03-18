{
  source,
  lib,
  stdenvNoCC,
  unzip,
}:

let
  appName = "OmniWM.app";
in
stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/${appName}
    cp -r . $out/Applications/${appName}

    runHook postInstall
  '';

  doInstallCheck = true;

  meta = {
    license = lib.licenses.gpl2;
    mainProgram = "omniwm";
    homepage = "https://github.com/BarutSRB/OmniWM";
    description = "MacOS Niri and Hyprland inspired tiling window manager that's developer signed and notorized (safe for managed enterprise environments)";
    platforms = lib.platforms.darwin;
    maintainers = [ ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
