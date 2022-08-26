{ lib
, stdenvNoCC
, fetchurl
, electron
, appimageTools
, makeWrapper

, pname, version, src, homepage, description, license
, _name ? null
}:

let
  meta = with lib; {
    inherit homepage description license;
    platforms = platforms.linux;
  };
  appimageContents = appimageTools.extract {
    inherit name src;
  };
  name = if (_name != null) then _name else "${pname}-${version}";
in

if (electron != null)
then stdenvNoCC.mkDerivation rec {
  inherit name src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share $out/share/applications
    cp -a ${appimageContents}/resources $out/share/
    cp -a ${appimageContents}/${pname}.desktop $out/share/applications/
    cp -a ${appimageContents}/usr/share/icons $out/share/
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/resources/app.asar
  '';
}
else appimageTools.wrapType2 {
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
}