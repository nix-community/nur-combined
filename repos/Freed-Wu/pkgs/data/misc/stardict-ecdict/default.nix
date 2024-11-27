{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "stardict-ecdict";
  version = "1.0.28";
  src = fetchurl {
    url = "https://github.com/skywind3000/ECDICT/releases/download/${version}/ecdict-stardict-28.zip";
    hash = "sha256-xwfQ897W7Hm5ZGbaShV04HRwPaWvnBIPutl/nLCMbyw=";
  };
  buildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/stardict/dic
    cp -r -- * $out/share/stardict/dic
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/skywind3000/ECDICT";
    description = "Free English to Chinese Dictionary Database";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
})
