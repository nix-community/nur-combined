{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "paste";
  version = "a70e672a";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = pname;
    rev = version;
    sha256 = "sha256-Lp5S1XPiH5cc+2JISv5FQYm6Wq81runZFugwocGILpQ=";
  };

  vendorHash = "sha256-kyMUsMa5IVI2KAX2ZUhaUX/WLF6RfB8Al4Gi9a4yDYU=";

  meta = with lib; {
    description = "Small temp redis-based pastebin server";
    homepage = "https://git.sr.ht/~artemis/paste";
  };
}
