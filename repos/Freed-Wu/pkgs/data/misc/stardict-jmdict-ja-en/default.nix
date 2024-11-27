{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "stardict-jmdict-ja-en";
  version = "2.4.2";
  src = fetchurl {
    url = "https://github.com/Freed-Wu/translate-shell/releases/download/0.0.1/${pname}-${version}.tar.bz2";
    hash = "sha256-WjosKgIHj4sqrbfZ9Qw4mUC2hMCq539VV7FBqnQfToc=";
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
    homepage = "http://www.edrdg.org/jmdict/j_jmdict.html";
    description = "Stardict Japanese-Multilingual Dictionary: Japanese to English";
    license = licenses.cc-by-sa-30;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
})
