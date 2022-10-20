{ lib
, stdenvNoCC
, fetchurl
, electron
, appimageTools
, makeWrapper

, pname, version, src, homepage, description, license
, _name ? null
, resourcesParentDir ? ""
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

stdenvNoCC.mkDerivation {
  inherit meta name src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/{applications,${pname}}
    cp -a ${appimageContents}/${resourcesParentDir}/resources/app.asar $out/share/${pname}
    cp -a ${appimageContents}/${pname}.desktop $out/share/applications/
    cp -a ${appimageContents}/usr/share/icons $out/share/
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/app.asar
  '';
}