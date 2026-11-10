{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  installFonts,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "maoken-assorted-sans";
  version = "1.70";

  src = fetchFromGitHub {
    owner = "maoken-fonts";
    repo = "MaokenAssortedSans";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kKuQtWuGgfuu0mMZKRXHUqVtkKAe0zh6OpVGNE4D++0=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = with lib; {
    homepage = "https://github.com/Skr-ZERO/MaokenAssortedSans";
    description = "A Chinese font derived from Nishiki-teki";
    license = licenses.ofl;
    platforms = platforms.all;
  };
})
