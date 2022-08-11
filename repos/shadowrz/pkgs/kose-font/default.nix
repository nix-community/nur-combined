{ lib, fetchFromGitHub }:

let
  pname = "kose-font";
  version = "20210514";
in
fetchFromGitHub {
  name = "${pname}-${version}";
  owner = "lxgw";
  repo = "kose-font";
  rev = "0d24786398fc8047b0b56b6dc521a02a2dcfd0d2";
  sha256 = "sha256-cnyHzFwlTsoPIxvZ4zeGsM9Nj+1E1Ow8BgZK+zhVSLo=";

  postFetch = ''
    tar xf $downloadedFile --strip=1
    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/kose-font
  '';

  meta = with lib; {
    homepage = "https://github.com/lxgw/kose-font";
    description =
      "A Chinese handwriting font derived from SetoFont / Naikai Font / cjkFonts-AllSeto.";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
