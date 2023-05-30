{ stdenv
, lib
, callPackage
, fetchurl
, gcc
}:

let
  funchook = callPackage ./funchook.nix {};
in
stdenv.mkDerivation rec {
  name = "ripcord-audio-hook";
  version = "v1.4";

  # fetchFromGitHub couldnt get the sources from any mirrors, use fetchurl for now
  src = fetchurl {
    url = "https://github.com/geniiii/ripcord-audio-hook/tarball/linux";
    sha256 = "1hc8g0d96fikq71bl9mizk18kqxv5zwwn64x2la7kd71qkfa6wf8";
  };

  unpackPhase = ''
    gunzip -c $src | tar xvf -
  '';

  nativeBuildInputs = [ funchook ];

  buildPhase = ''
    gcc -shared -fPIC -o hook.so geniii*/hook.c -ldl -lfunchook
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp hook.so $out/lib
  '';

  meta = with lib; {
    description = "Fixes Ripcord's voice chat functionality";
    homepage = "https://github.com/geniiii/ripcord-audio-hook/tree/master";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
