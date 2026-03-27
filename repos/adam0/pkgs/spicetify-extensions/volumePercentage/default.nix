{
  fetchFromGitHub,
  lib,
  mkSpicetifyExtension,
}:
mkSpicetifyExtension {
  src = fetchFromGitHub {
    owner = "jeroentvb";
    repo = "spicetify-volume-percentage";
    rev = "030c36b8903a99fa06405dae65b66fa4910eff99";
    hash = "sha256-UM+8dX4OeaxmZ99sjGF7uJhAoRdhxTqgXU5F3FOlUU4=";
  };

  name = "volumePercentage.js";

  meta = with lib; {
    description = "Show volume percentage in Spicetify";
    homepage = "https://github.com/jeroentvb/spicetify-volume-percentage";
    license = licenses.mit;
  };
}
