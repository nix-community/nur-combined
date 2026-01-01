{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "helium";
  src = fetchurl (lib.helper.getPlatform platform ver);

  version = lib.helper.getVersion platform ver;

  meta = {
    description = "Private, fast, and honest web browser (nightly builds)";
    homepage = "https://github.com/imputnet/helium";
    changelog = "https://github.com/imputnet/helium/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = ["Ev357" "Prinky"];
    platforms = lib.platforms.unix;
    mainProgram = "helium";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];

      sourceRoot = ".";

      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r Helium.app $out/Applications/
        runHook postInstall
      '';
    }
  else
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = let
        contents = appimageTools.extract {inherit pname version src;};
      in ''
        install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'

        cp -r ${contents}/usr/share/* $out/share/

        install -d $out/share/lib/${pname}
        cp -r ${contents}/opt/${pname}/locales $out/share/lib/${pname}/
      '';
    }
