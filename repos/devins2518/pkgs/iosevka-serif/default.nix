{ lib, fetchFromGitHub }:

fetchFromGitHub rec {
  name = "iosevka-serif";

  owner = "devins2518";
  repo = "iosevka-serif";
  rev = "270e7139d719aa52e525697f36b03fe10ef90722";
  sha256 = "sha256-vHXoPhrmdNv65KvW/66QhMLBuW/9kAoc2hRDOse/654=";

  postFetch = ''
    tar xzf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/truetype
    install out/*.ttf $out/share/fonts/truetype
    install norm/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/devins2518/iosevka-serif";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ devins2518 ];
  };
}
