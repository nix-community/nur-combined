{ lib, buildGoModule, fetchFromSourcehut }:
buildGoModule rec {
  pname = "paste";
  version = "dev-a70e672a.rev1";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = pname;
    rev = "a70e672a";
    sha256 = "sha256-Lp5S1XPiH5cc+2JISv5FQYm6Wq81runZFugwocGILpQ=";
  };

  vendorHash = "sha256-kyMUsMa5IVI2KAX2ZUhaUX/WLF6RfB8Al4Gi9a4yDYU=";
  
  postInstall =
    ''
    mkdir -p $out/lib/${pname}
    cp -r templates $out/lib/${pname}
    cp -r static $out/lib/${pname}
    '';

  # TODO: The output doesn't include the templates files and it doesn't properly
  # "automatically reference the templates file path" either.
  # More to do with how i coded it than nix tbh but still.

  meta = with lib; {
    description = "Small temp redis-based pastebin server";
    homepage = "https://git.sr.ht/~artemis/paste";
  };
}
