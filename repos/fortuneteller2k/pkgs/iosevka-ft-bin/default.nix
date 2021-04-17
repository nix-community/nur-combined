{ lib, fetchFromGitHub }:

let
  version = "5.0.5";
in fetchFromGitHub rec {
  name = "iosevka-ft-bin-${version}";
  
  owner = "fortuneteller2k";
  repo = "iosevka-ft";
  rev = "81b7c36143b4982e452143bf926e3c4a57c2c025";
  sha256 = "sha256-2gfprvU4yJNjAgf/Us3vaoY3d9DQPVG4mU+tn3Cubuw=";

  postFetch = ''
    tar xzf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/truetype
    install truetype/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Custom build of Iosevka by fortuneteller2k";
    homepage = "https://github.com/fortuneteller2k/iosevka-ft";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
