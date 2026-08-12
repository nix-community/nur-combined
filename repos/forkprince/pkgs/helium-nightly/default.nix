# NOTE: Widevine does not work on MacOS
{
  enableWidevine ? false,
  # google-chrome ? null,
  widevine-cdm ? null,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;

  pname = "helium";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  version = lib.helper.getVersion stdenvNoCC.hostPlatform.system ver;

  meta = {
    description = "Private, fast, and honest web browser (nightly builds)";
    homepage = "https://github.com/imputnet/helium";
    changelog = "https://github.com/imputnet/helium/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [Prinky Ev357 LarsArtmann];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "helium";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];

      # installPhase = ''
      #   runHook preInstall
      #
      #   mkdir -p $out/Applications
      #   cp -r Helium.app $out/Applications/
      #
      #   ${lib.optionalString enableWidevine ''
      #     cp -R "${google-chrome}/Applications/Google Chrome.app/Contents/Frameworks/Google Chrome Framework.framework/Libraries/WidevineCdm" "$out/Applications/Helium.app/Contents/Frameworks/Helium Framework.framework/Libraries"
      #   ''}
      #
      #   runHook postInstall
      # '';
    })
  else let
    contents = appimageTools.extract {
      inherit pname version src;
      postExtract = lib.optionalString enableWidevine ''
        ln -s ${widevine-cdm}/share/google/chrome/WidevineCdm $out/opt/${pname}/WidevineCdm
      '';
    };
  in
    appimageTools.wrapAppImage {
      inherit pname version;
      src = contents;

      extraPreBwrapCmds = lib.optionalString enableWidevine ''
        WIDEVINE_HINT="''${XDG_CONFIG_HOME:-$HOME/.config}/Helium/WidevineCdm/latest-component-updated-widevine-cdm"
        CDM_PATH="${widevine-cdm}/share/google/chrome/WidevineCdm"
        mkdir -p "$(dirname "$WIDEVINE_HINT")"
        echo '{"Path":"'"$CDM_PATH"'"}'> "$WIDEVINE_HINT"
      '';

      meta =
        meta
        // lib.optionalAttrs enableWidevine {
          license = lib.licenses.unfree;
        };

      extraInstallCommands = ''
        install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-warn 'Exec=AppRun' 'Exec=${meta.mainProgram}' \
          --replace-warn 'Exec=${pname}' 'Exec=${meta.mainProgram}'

        cp -r ${contents}/usr/share/* $out/share/

        install -d $out/share/lib/${pname}
        cp -r ${contents}/opt/${pname}/locales $out/share/lib/${pname}/
      '';
    }
