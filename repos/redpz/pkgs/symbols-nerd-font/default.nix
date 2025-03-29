{
  stdenv,
  fetchurl,
  unzip,
  lib,
}:

stdenv.mkDerivation rec {
  name = "symbols-nerd-font";
  version = "3.3.0";
  src = fetchurl {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/NerdFontsSymbolsOnly.zip";
    hash = "sha256-IHhgPB56L8L6nmJbocMCZNXXw5kHgT2Jvqo3P3Ojo0A=";
  };

  nativeBuildInputs = [
    unzip
  ];

  unpackPhase = ''
    unzip $src -d extracted
  '';

  installPhase = ''
    runHook preInstall
    # find extracted -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find extracted -name '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.nerdfonts.com/";
    description = "Just the Nerd Font Icons. I.e Symbol font only";
    license = licenses.free;
    platforms = platforms.all;
  };
}
