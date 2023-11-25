{ lib
, fetchurl
, appimageTools
, makeWrapper
}:

let
  pname = "anytype";
  version = "0.36.0";
  name = "Anytype-${version}";
  nameExecutable = pname;
  src = fetchurl {
    url = "https://github.com/anyproto/anytype-ts/releases/download/v${version}/Anytype-${version}.AppImage";
    hash = "sha256-Efoqy/izULDgd2Dc3ktVZNj9/U0vCtENm0NLr5VKQpQ=";
  };
  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
    ++ [ pkgs.libsecret ];

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    source "${makeWrapper}/nix-support/setup-hook"
    install -m 444 -D ${appimageContents}/anytype.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/anytype.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/0x0/apps/anytype.png \
      $out/share/icons/hicolor/512x512/apps/anytype.png
  '';

  meta = with lib; {
    description = "P2P note-taking tool";
    homepage = "https://anytype.io";
    license = licenses.unfree;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = [ "x86_64-linux" ];
  };
}
