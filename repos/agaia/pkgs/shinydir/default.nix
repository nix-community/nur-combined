{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "shinydir";
  version = "v0.1.2";

  src = fetchFromGitHub {
    owner = "Unoqwy";
    repo = pname;
    rev = version;
    hash = "sha256-n6yJ9iE9lThkRkMjyIzGZ+Hi/sS6tYFfngC7sYiJHIw=";
  };

  cargoHash = "sha256-71cDG7Jplny9RI3glIH9qBtlGYDn4C4tkGCHUmlvkjk=";

  meta = with lib; {
    platforms = platforms.all;
  };
}
