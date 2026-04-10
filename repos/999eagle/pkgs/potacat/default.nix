{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron,
}:
buildNpmPackage (finalAttrs: {
  pname = "potacat";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "Waffleslop";
    repo = "POTACAT";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IhTvDbAG6sjY9lkL6WcbFPULf/MFpc+Wy+7ziwX3gnM=";
  };

  npmDepsHash = "sha256-VTLToyWzcv/iuP436OY9PdXfbMYG6/IRa3Z6u0gT9iw=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    npm exec electron-builder --linux -- \
      --dir \
      -c.electronDist=${electron.dist} \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ls -alh dist/*-unpacked/

    mkdir -p $out/share/potacat $out/bin
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/potacat

    makeWrapper ${lib.getExe electron} $out/bin/potacat \
      --add-flags $out/share/potacat/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = "potacat";
    homepage = "https://github.com/Waffleslop/POTACAT";
    license = licenses.mit;
  };
})
