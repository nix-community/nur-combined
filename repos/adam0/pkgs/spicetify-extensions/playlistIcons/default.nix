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
    description = "Add the icon of a playlist in front of the playlist in the playlist list";
    homepage = "https://github.com/jeroentvb/spicetify-playlist-icons";
    license = licenses.mit;
  };
}
