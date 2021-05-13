{ lib, fetchFromGitHub }:

let
  version = "6.1.3";
in
fetchFromGitHub rec {
  name = "iosevka-ft-bin-${version}";

  owner = "fortuneteller2k";
  repo = "iosevka-ft";
  rev = "a8815ff860b820c13612ef4e34589ed77c727aac";
  sha256 = "sha256-baV0UWj9oEQaT2K9FstiFF9C7HGpCT8m+go/y4rIJBg=";

  postFetch = ''
    tar xzf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/truetype
    install truetype-v6/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Custom build of Iosevka by fortuneteller2k";
    homepage = "https://github.com/fortuneteller2k/iosevka-ft";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
