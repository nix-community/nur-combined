{ appimageTools, lib, fetchurl, rp ? "" }:
let
  pname = "lx-music-desktop";
  version = "1.22.1";
  name = "${pname}-v${version}";

  src = fetchurl {
    url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${name}-x64.AppImage";
    sha256 = "d0a490f26f4056fb5f49ee70dd2aac0a9771d51824e3133112ec5e66d876db8a";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 \
      -D ${appimageContents}/${pname}.desktop \
      -t $out/share/applications

    substituteInPlace \
        $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'

    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "A music application based on electron";
    license = licenses.asl20;
    homepage = "https://github.com/lyswhut/lx-music-desktop";
    platforms = platforms.linux;
  };
}