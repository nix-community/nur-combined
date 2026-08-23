{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
}:

stdenv.mkDerivation {
  pname = "xpilot-plugin";
  version = "4.0.0-beta.6";

  # The xPilot client (pkgs/xpilot) is only the desktop app; the X-Plane
  # plugin it talks to over a socket ships separately. The download manifest
  # at https://downloads.xpilot.app lists it as pluginPackage.linux. The
  # plugin version must match the client's, or the client rejects it during
  # its plugin-version handshake, so keep this version in lock-step with
  # pkgs/xpilot.
  src = fetchurl {
    url = "https://downloads.xpilot.app/artifacts/4.0.0-beta.6/Plugin-linux.zip";
    hash = "sha256-oFvBHlf75HylzuXytZKuyPf9xJBJVKV3mqbZ90uoXDw=";
    name = "xpilot-plugin-4.0.0-beta.6.zip";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  # xPilot.xpl is a plain ELF shared object dlopen'd by X-Plane; it only needs
  # the C++ runtime, which is not on a default search path on NixOS.
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
