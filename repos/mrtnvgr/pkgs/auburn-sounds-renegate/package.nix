{
  stdenvNoCC,
  lib,
  fetchzip,
  autoPatchelfHook,
  libX11,
  libgcc,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "auburn-sounds-renegate";
  version = "1.6";

  src = fetchzip {
    url = "https://www.auburnsounds.com/downloads/Renegate-FREE-${finalAttrs.version}.zip";
    hash = "sha256-qr+IshJ94zBwaUf41spA3sfVVnTOdT1do3GcC7dhJ3w=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libX11
    libgcc
  ];

  installPhase =
    let
      mkInstaller = format: ''
        mkdir -p $out/lib/${format}
        cp -r "Linux-64b-${lib.toUpper format}-FREE/Auburn Sounds Renegate.${format}" $out/lib/${format}
      '';
      mkInstallers = formats: lib.concatStringsSep "\n" (map mkInstaller formats);
    in
    ''
      runHook preInstall

      pushd Linux
        ${mkInstallers [
          "clap"
          "lv2"
          "vst3"
        ]}
      popd

      runHook postInstall
    '';

  meta = {
    description = "Full-band Gate plug-in";
    homepage = "https://www.auburnsounds.com/products/Renegate.html";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.mrtnvgr ];
  };
})
