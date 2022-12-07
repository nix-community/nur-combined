{ appimageTools, lib, fetchurl, electron, makeWrapper, libsecret }:

let
  pname = "qq";
  version = "2.0.1-429";
  name = "Tencent-QQ-${version}";

  src = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/4691a571/QQ-v${version}_x64.AppImage";
    sha256 = "sha256-7izsmUwfEAcQHj6PNcU/cprJRNHj342I62kW316vKo8=";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit version name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  passthru.version = version;

  extraPkgs = pkgs: with pkgs; [
    libsecret
    libappindicator-gtk3
  ];

  meta = with lib; {
    homepage = "https://qq.com";
    description = "Official Tencent QQ client for Linux (Beta)";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}