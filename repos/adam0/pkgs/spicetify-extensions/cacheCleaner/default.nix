{
  fetchFromGitHub,
  lib,
  mkSpicetifyExtension,
}:
mkSpicetifyExtension {
  src = fetchFromGitHub {
    owner = "kyrie25";
    repo = "Spicetify-Cache-Cleaner";
    rev = "8d0ec54581920629734acc5e4449d34d6afce7fb";
    hash = "sha256-VuBbW4xYpB2QbSsNjR1an05WMXhLU9rv9moHw/DgCgk=";
  };

  name = "cacheCleaner.js";

  meta = with lib; {
    description = "Clear Spotify cache from Spicetify";
    homepage = "https://github.com/kyrie25/Spicetify-Cache-Cleaner";
    license = licenses.gpl3Only;
  };
}
