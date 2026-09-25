{
  lib,
  stdenvNoCC,
  fetchurl,

  p7zip,
  installFonts,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "th-tshyn";
  version = "5.0.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "http://cheonhyeong.com/File/TH-Tshyn-5.0.0.7z";
    hash = "sha256-cqYgRfj3busbxVuQbKYdD+jcx3mDkfUrtFgQDpEdazM=";
  };

  unpackPhase = ''
    runHook preUnpack

    7z x -aoa $src

    runHook postUnpack
  '';

  nativeBuildInputs = [
    p7zip
    installFonts
  ];

  meta = {
    description = "TH-Tshyn Chinese font";
    homepage = "http://cheonhyeong.com/";
    downloadPage = "http://cheonhyeong.com/Simplified/download.html";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
