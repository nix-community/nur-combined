{ lib
, stdenvNoCC
, fetchurl
, electron
, appimageTools
, makeWrapper

, pname, version, src, homepage, description, license
, _name ? null
, resourcesParentDir ? ""
, extraPkgs ? null
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

if (extraPkgs == null)
then stdenvNoCC.mkDerivation {
  inherit meta name src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/applications
    cp -a ${appimageContents}/${resourcesParentDir}/resources $out/share/${pname}
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
else appimageTools.wrapAppImage {
  inherit meta name extraPkgs;

  src = appimageContents;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 \
      -D ${appimageContents}/${pname}.desktop \
      -t $out/share/applications

    substituteInPlace \
        $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'

    sed -i 's/Icon=.*/Icon=${pname}/' $out/share/applications/${pname}.desktop

    cp -r ${appimageContents}/usr/share/icons $out/share
  '';
}