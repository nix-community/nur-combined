{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  meta = with lib; {
    description = "A Zellij plugin to remember your keybinds and all the other things you want to remember";
    homepage = "https://github.com/karimould/zellij-forgot";
    license = licenses.free; # TODO License not defined in repo
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = null;
  };

  pname = "zellij-forgot";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/karimould/zellij-forgot/releases/download/${version}/zellij_forgot.wasm";
    sha256 = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zellij/plugins
    cp $src $out/share/zellij/plugins/zellij-forgot-${version}.wasm

    runHook postInstall
  '';
}