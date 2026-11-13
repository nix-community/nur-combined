{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkSpicetifyExtension,
  # keep-sorted end
}:
mkSpicetifyExtension {
  src = fetchFromGitHub {
    owner = "jeroentvb";
    repo = "spicetify-playlist-icons";
    rev = "6beb6c85f0c752f692f52a93f7c0f33b3b81a28a";
    hash = "sha256-zmJWR1FeazFmM3qSa9L2tcU9RkdiGYpvoBbHFi+SRSI=";
  };

  name = "playlist-icons.js";

  meta = with lib; {
    # keep-sorted start
    description = "Add the icon of a playlist in front of the playlist in the playlist list";
    homepage = "https://github.com/jeroentvb/spicetify-playlist-icons";
    license = licenses.mit;
    # keep-sorted end
  };
}
