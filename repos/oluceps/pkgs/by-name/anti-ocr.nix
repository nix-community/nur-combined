{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anti-ocr";

  version = "unstable-2019-01-28";

  src = fetchFromGitHub {
    owner = "yuzu233";
    repo = "anti-ocr";
    rev = "04bd8d01dd34c78d6818fe6e39acfdc258dece7d";
    hash = "sha256-kdjy5xNKV19BQ2rzMoRaHYWGiIw9E0vjE1G0/27GdVo=";
  };

  installPhase = ''
    mkdir -p $out
    install -D ./index.html $out
    install -D ./main.js $out
  '';

  meta = with lib; {
    homepage = "https://github.com/yuzu233/anti-ocr";
    platforms = platforms.all;
    maintainers = with maintainers; [ oluceps ];
  };
})
