{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "stardict-langdao-ec-gb";
  version = "2.4.2";
  src = fetchurl {
    url = "https://github.com/Freed-Wu/translate-shell/releases/download/0.0.1/${pname}-${version}.tar.bz2";
    hash = "sha256-ir15g35HixYaJ2XpnlCLGCR1zlk1sUGhDYqT6Uzbhkc=";
  };
  unpackPhase = ''
    tar vxaf ${src}
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/stardict/dic
    cp -r -- * $out/share/stardict/dic
    rm -f $out/share/stardict/dic/env-vars
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "http://download.huzheng.org/";
    description = "LangDao English-Chinese Dictionary for StarDict";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
})
