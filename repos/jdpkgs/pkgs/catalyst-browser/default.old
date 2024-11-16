{ stdenv
, lib
, fetchurl
, appimageTools
, makeWrapper
, electron_28
, electronPackage ? electron_28
, asar
}:

let
  electron = electronPackage;
in
stdenv.mkDerivation rec {
  pname = "catalyst3";
  version = "3.5.4";

  src = fetchurl {
    url = "https://github.com/CatalystDevOrg/Catalyst/releases/download/v${version}/catalyst-${version}.AppImage";
    sha256 = "f0H/ekhgpvF22rZkBlopLi+D1P+2CMp09+trkyRs4Ko=";
    name = "${pname}-${version}.AppImage";
  };

  buildInputs = [
    asar
  ];

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications
    mkdir -p $out/share/${pname}/resources/

    cp -a ${appimageContents}/locales $out/share/${pname}
    cp -a ${appimageContents}/catalyst.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons $out/share
    asar extract ${appimageContents}/resources/app.asar resources/
    rm -rf resources/.github
    rm -rf resources/.vscode
    rm -rf resources/.eslintrc.json
    rm -rf resources/.gitignore
    rm -rf resources/.pnpm-debug.log
    rm -rf resources/contributing.md
    rm -rf resources/pnpm-lock.yaml
    rm -rf resources/README.md
    rm -rf resources/tailwind.config.js
    rm -rf resources/CODE_OF_CONDUCT.md
    sed -i 's/catalyst-default-distrib/catalyst-default-nix/g' resources/src/index.html
    asar pack resources/ $out/share/${pname}/resources/app.asar

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=catalyst' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc ]}"
  '';

  meta = with lib; {
    description = "Catalyst web browser";
    homepage = "https://github.com/CatalystDevOrg/Catalyst";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
