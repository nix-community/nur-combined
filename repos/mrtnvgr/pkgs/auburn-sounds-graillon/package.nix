{
  stdenvNoCC,
  lib,
  fetchzip,
  autoPatchelfHook,
  libX11,
  libgcc,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "auburn-sounds-graillon";
  version = "3.2";

  src = fetchzip {
    url = "https://www.auburnsounds.com/downloads/Graillon-FREE-${finalAttrs.version}.zip";
    hash = "sha256-qM8Ydhbc5nuv9BD6QbGELv+CQt5Vprsxu/7O97TkpsY=";
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
        cp -r "Linux-64b-${lib.toUpper format}-FREE/Auburn Sounds Graillon 3.${format}" $out/lib/${format}
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
    description = "Enhanced pitch correction tool";
    homepage = "https://www.auburnsounds.com/products/Graillon.html";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.mrtnvgr ];
  };
})
