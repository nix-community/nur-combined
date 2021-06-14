{ lib, fetchFromGitHub }:

let
  version = "7.0.4";
in
fetchFromGitHub rec {
  name = "iosevka-ft-bin-${version}";

  owner = "fortuneteller2k";
  repo = "iosevka-ft";
  rev = "d6a0ec816672bc5b82813a6a5e4b17bbe09e04e1";
  sha256 = "sha256-EX/PJfFDgYyd7PbhjIJSHqvw14g2zv0dcgWwEEYKEaU=";

  postFetch = ''
    tar xzf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/truetype
    install truetype-v7/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Custom build of Iosevka by fortuneteller2k";
    homepage = "https://github.com/fortuneteller2k/iosevka-ft";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
