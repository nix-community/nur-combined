{ lib, fetchzip }:

let
  version = "1.2-11.2.2";
in fetchzip {
  name = "bmono-${version}";
  url = "https://github.com/NNBnh/bmono/releases/download/v${version}/bmono-ttf.zip";
  sha256 = "sha256-/o3IyGlhWm45rxWW3bD4FLeCjiNP8HWx5BZVGFrryXI=";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.ttf -d $out/share/fonts/truetype
  '';

  meta = with lib; {
    homepage = "https://github.com/NNBnh/bmono";
    downloadPage = "https://github.com/NNBnh/bmono/releases";
    description = "Mono font that SuperB";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
