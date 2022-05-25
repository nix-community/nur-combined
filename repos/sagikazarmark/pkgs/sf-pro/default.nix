{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "sf-pro";
  version = "20220523-8bfea09a";

  src = fetchFromGitHub {
    owner = "sahibjotsaggu";
    repo = "San-Francisco-Pro-Fonts";
    rev = "8bfea09aa6f1139479f80358b2e1e5c6dc991a58";
    sha256 = "sha256-mAXExj8n8gFHq19HfGy4UOJYKVGPYgarGd/04kUIqX4=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/{truetype,opentype}
    cp *.ttf $out/share/fonts/truetype/
    cp *.otf $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "San Francisco Pro fonts by Apple";
    homepage = "https://developer.apple.com/fonts/";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ sagikazarmark ];
  };
}
