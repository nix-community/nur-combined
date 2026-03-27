{
  fetchFromGitHub,
  lib,
  mkSpicetifyExtension,
}:
mkSpicetifyExtension {
  src = fetchFromGitHub {
    owner = "jeroentvb";
    repo = "spicetify-playlist-icons";
    rev = "dist";
    hash = "sha256-hOkFIAperiWzfR+EVVAxEdta9LRndJbjritMj4I0gNw=";
  };

  name = "playlist-icons.js";

  meta = with lib; {
    description = "Add playlist icons to Spicetify";
    homepage = "https://github.com/jeroentvb/spicetify-playlist-icons";
    license = licenses.mit;
  };
}
