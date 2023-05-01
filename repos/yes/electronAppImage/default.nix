{ lib
, stdenv
, fetchurl
, electron
, appimageTools
, makeWrapper
}:

{ pname, version, src, meta
, _name ? null
, resourcesParentDir ? ""
, runtimeLibs ? []
}:

let
  appimageContents = appimageTools.extract {
    inherit name src;
  };
  name = if (_name != null) then _name else "${pname}-${version}";
in

stdenv.mkDerivation {
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
      --add-flags $out/share/${pname}/app.asar \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru = {
    inherit electron;
  };
}