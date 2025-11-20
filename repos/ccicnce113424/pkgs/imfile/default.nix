{
  fetchedSrc,
  lib,
  stdenv,
  appimageTools,
}:
let
  imfileSrc = {
    "x86_64-linux" = fetchedSrc.imfile-x86;
    "aarch64-linux" = fetchedSrc.imfile-arm;
  };
  sources = imfileSrc.${stdenv.hostPlatform.system};
in
appimageTools.wrapType2 rec {
  pname = "imfile";
  inherit (sources) src version;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -D ${appimageContents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'

      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

  meta = {
    description = "Full-featured download manager";
    homepage = "https://github.com/imfile-io/imfile-desktop";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "imfile";
    platforms = builtins.attrNames imfileSrc;
  };
}
