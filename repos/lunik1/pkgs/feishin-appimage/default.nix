{ lib, appimageTools, fetchurl, imagemagick }:

let
  pname = "feishin";
  version = "0.6.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/jeffvli/feishin/releases/download/v${version}/Feishin-${version}-linux-x86_64.AppImage";
    sha256 = "sha256-/jLtPZHIiz67hqGRwaij3hsc23dYfTJQdilGFLJ8U8I=";
  };

  icon = fetchurl {
    url =
      "https://raw.githubusercontent.com/jeffvli/feishin/v${version}/assets/icons/1024x1024.png";
    sha256 = "sha256-atvzlxBeuAgUS/bgKm7qW4iVruggSLAMNgRFve89ZT8=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/feishin.desktop $out/share/applications/feishin.desktop
    substituteInPlace $out/share/applications/feishin.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      ${imagemagick}/bin/convert -resize "$size"x"$size" ${icon} $out/share/icons/hicolor/"$size"x"$size"/apps/feishin.png
    done
    install -m 444 -D ${icon} $out/share/icons/hicolor/1024x1024/apps/feishin.png
  '';

  meta = with lib; {
    description = "A modern self-hosted music player (AppImage).";
    homepage = "https://github.com/jeffvli/feishin";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ lunik1 ];
    platforms = [ "x86_64-linux" ];
  };
}
