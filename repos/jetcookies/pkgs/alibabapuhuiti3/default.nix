{
  lib,
  stdenvNoCC,
  fetchurl,

  p7zip,
  installFonts,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "alibabapuhuiti3";
  version = "3.0.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://fonts.alibabadesign.com/AlibabaPuHuiTi-3.zip";
    curlOptsList = [ "-e https://www.alibabafonts.com/" ]; # fonts.alibabadesign.com has enabled Referer anti-hotlinking; a Referer from the same domain is required to download files.
    hash = "sha256-8l9zC2p2YbzVuXZNyY8F06wl7ncZd88Esx7V+6n0lqc=";
  };

  unpackPhase = ''
    runHook preUnpack

    7z x -aoa $src
    rm -r __MACOSX

    runHook postUnpack
  '';

  nativeBuildInputs = [
    p7zip
    installFonts
  ];

  outputs = [
    "out"
    "webfont" # .woff or .woff2 output
  ];

  meta = {
    description = "AlibabaPuHuiTi-3 Simplified Chinese font";
    homepage = "http://www.alibabafonts.com";
    downloadPage = "https://www.alibabafonts.com/#/font";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
