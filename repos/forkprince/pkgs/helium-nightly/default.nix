{
  appimageTools,
  fetchurl,
  pkgs,
  lib,
  ...
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  inherit (info) version;

  platform = lib.getAttr pkgs.system info.platforms;

  filename = lib.replaceStrings ["{version}"] [version] platform.file;
in
  appimageTools.wrapType2 rec {
    pname = "helium";

    inherit version;

    src = fetchurl {
      inherit (platform) hash;
      url = "https://github.com/${info.repo}/releases/download/${info.version}/${filename}";
    };

    extraInstallCommands = let
      contents = appimageTools.extract {inherit pname version src;};
    in ''
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'

      cp -r ${contents}/usr/share/* $out/share/

      install -d $out/share/lib/${pname}
      cp -r ${contents}/opt/${pname}/locales $out/share/lib/${pname}/
    '';

    meta = {
      description = "Private, fast, and honest web browser (nightly builds)";
      homepage = "https://github.com/imputnet/${pname}";
      changelog = "https://github.com/${info.repo}/releases/tag/${version}";
      license = lib.licenses.gpl3;
      maintainers = ["Ev357" "Prinky"];
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = pname;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
