{ fetchFromGitHub
, installFonts
, lib
, stdenv
, unstableGitUpdater
}:

let
  inherit (lib) licenses;
in
stdenv.mkDerivation {
  pname = "cc-icons-unicode";
  version = "0-unstable-2020-09-29";
  meta = {
    description = "Font for the Creative Commons symbols in Unicode";
    homepage = "https://github.com/FriedOrange/CCIconsUnicode";
    license = licenses.cc0;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "FriedOrange";
    repo = "CCIconsUnicode";
    rev = "c3615afea130e643db31b7f7c352dac760bb2ff6";
    hash = "sha256-U8Vb/HoaiIIZ5HkM9myZ0zAEoL8TGXrwiRAhHgI0Az0=";
  };

  nativeBuildInputs = [ installFonts ];

  outputs = [ "out" "webfont" ];
}
