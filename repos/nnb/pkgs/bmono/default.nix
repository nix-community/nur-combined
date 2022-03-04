{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  version = "1.2-11.2.2";
  name = "bmono-${version}";
  src = fetchzip {
    url = "https://github.com/NNBnh/bmono/releases/download/v${version}/bmono-ttf.zip";
    hash = "sha256-/o3IyGlhWm45rxWW3bD4FLeCjiNP8HWx5BZVGFrryXI=";
  };
  buildCommand = "install -D --target $out/share/fonts/truetype/ $src/*";

  meta = with lib; {
    homepage = "https://github.com/NNBnh/bmono";
    downloadPage = "https://github.com/NNBnh/bmono/releases";
    description = "Mono font that SuperB ";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
