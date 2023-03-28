{ lib
, stdenvNoCC
}:

stdenvNoCC.mkDerivation rec {
  pname = "lzturbo";
  version = "1.2";

  src = builtins.fetchurl {
    url = "https://archive.org/download/lzturbo-1.2/lzturbo_static";
    sha256 = "sha256:7d6717e99f189a4255688f8db8f29c8076afabd12c84edb2de0b9ece78080d4b";
  };

  buildCommand = ''
    mkdir -p $out/bin
    cp $src $out/bin/lzturbo
    chmod +x $out/bin/lzturbo
  '';

  meta = with lib; {
    description = "high-performance file compressor";
    homepage = "https://sites.google.com/site/powturbo";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}
