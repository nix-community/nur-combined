{ lib, fetchFromGitHub }:

let
  version = "7.0.4";
in
fetchFromGitHub rec {
  name = "iosevka-ft-bin-${version}";

  owner = "fortuneteller2k";
  repo = "iosevka-ft";
  rev = "d53fac058c3f1c280b926e68efe98f90653b3db6";
  sha256 = "sha256-ptD67bJTAufdqIjqGbeimupIq7dJ6qb5ZjnWpBXfgkw=";

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
