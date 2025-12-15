{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  undmg,
  pkgs,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  platform = pkgs.stdenv.hostPlatform.system;

  pname = "helium";
  src = fetchurl (lib.helper.getPlatform platform ver);

  inherit (ver) version;

  meta = {
    description = "Private, fast, and honest web browser (nightly builds)";
    homepage = "https://github.com/imputnet/helium";
    changelog = "https://github.com/imputnet/helium/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = ["Ev357" "Prinky"];
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    mainProgram = "helium";
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [undmg];

      unpackPhase = ''
        runHook preUnpack
        undmg "$src"
        runHook postUnpack
      '';

      sourceRoot = ".";

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
