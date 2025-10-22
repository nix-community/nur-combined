{
  fetchurl,
  appimageTools,
  lib,
  ...
}: let
  pname = "JMComic-qt";
  version = "1.2.9";
  src = fetchurl {
    url = "https://github.com/tonquer/${pname}/releases/download/v${version}/jmcomic_v${version}_linux-glibc2.38.AppImage";
    hash = "sha256-LgHR+HDfTb9Ur8p4Ibb8TUdLqwkK8wKynrKliYbEGSg=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    src = appimageContents;
    extraPkgs = pkgs: [
      (pkgs.libxcb or pkgs.xorg.libxcb)
      (pkgs.libxcb-util or pkgs.xorg.xcbutil)
    ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/JMComic.desktop $out/share/applications/
      mkdir -p $out/share/pixmaps
      cp ${appimageContents}/JMComic.png $out/share/pixmaps/
      substituteInPlace $out/share/applications/JMComic.desktop --replace-fail 'Exec=JMComic' 'Exec=${pname}'
    '';
    meta = with lib; {
      description = "tonquer/JMComic-qt: 禁漫天堂，18comic，使用qt实现的PC客户端，支持Windows，Linux，MacOS";
      homepage = "https://github.com/tonquer/JMComic-qt";
      platforms = with platforms; (intersectLists x86_64 linux);
      license = with licenses; [lgpl3];
      mainProgram = pname;
      sourceProvenance = with sourceTypes; [binaryBytecode];
    };
  }
