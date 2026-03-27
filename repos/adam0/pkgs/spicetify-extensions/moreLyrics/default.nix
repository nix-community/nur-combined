{
  fetchFromGitHub,
  lib,
  mkSpicetifyExtension,
}:
mkSpicetifyExtension {
  src = "${fetchFromGitHub {
    owner = "Kamiloo13";
    repo = "spicetify-extensions";
    rev = "bfad7427ef6385a27cdb7a9e3b2851a76702b896";
    hash = "sha256-hFjPE4zUPV6qnw/FWc1TG1l2gPdPFa+umBlF3A+2DnM=";
  }}/extensions/more-lyrics/dist";

  name = "more-lyrics.js";

  meta = with lib; {
    description = "Show more lyrics providers in Spicetify";
    homepage = "https://github.com/Kamiloo13/spicetify-extensions";
    license = licenses.mit;
  };
}
