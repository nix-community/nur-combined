{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenvNoCC,

  installFonts,
}:
stdenvNoCC.mkDerivation {
  pname = "sofia-sans";
  version = "0-unstable-2023-01-12";
  src = fetchFromGitHub {
    owner = "lettersoup";
    repo = "Sofia-Sans";
    rev = "9a1f0ba30f0139b011f9e69c9c462728fa5ef725";
    hash = "sha256-oh+gl9yhkFdrTMPh2jYjUy6bwrykMteE9BzmlakPfk0=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Comprehensive type system in four widths with extended coverage of the Latin-, Greek- and Cyrillic Script";
    homepage = "https://github.com/lettersoup/Sofia-Sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
