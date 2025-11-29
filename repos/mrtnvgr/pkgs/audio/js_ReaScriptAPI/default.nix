{
  fetchFromGitHub,
  fetchurl,
  stdenv,
  lib,
  gcc,
  pkg-config,
  gtk3,
  libsysprof-capture,
  pcre2,
  util-linux,
  libselinux,
  libsepol,
  libthai,
  libdatrie,
  libxdmcp,
  libdeflate,
  lerc,
  xz,
  zstd,
  libwebp,
  libxkbcommon,
  libepoxy,
  libxtst,
  zlib,
}:

let
  version = "1.310.101";

  majorMinorVersion = lib.versions.majorMinor version;

  dll = fetchurl {
    url = "https://github.com/juliansader/ReaExtensions/raw/master/js_ReaScriptAPI/v${majorMinorVersion}/reaper_js_ReaScriptAPI64.dll";
    hash = "sha256-cjGGIkfvzZNfFKZINk94CGMcuZsP1V617Wrx+/dAUHI=";
  };
in

stdenv.mkDerivation {
  pname = "js_ReaScriptAPI";
  inherit version;

  src = fetchFromGitHub {
    owner = "juliansader";
    repo = "js_ReaScriptAPI";
    rev = "52b2f2c6eae11437acabbd7a1e6017820cfb6ee3";
    hash = "sha256-QdBzVwvi0JpKBUVyVNrTzIPlmLAEr3PemdaRoW+oVD8=";
  };

  nativeBuildInputs = [ gcc pkg-config ];

  buildInputs = [
    gtk3
    libsysprof-capture
    pcre2
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    libxdmcp
    libdeflate
    lerc
    xz
    zstd
    libwebp
    libxkbcommon
    libepoxy
    libxtst
    zlib
  ];

  buildPhase = ''
    runHook preBuild

    # === Taken from src/.appveyor.yml ===
    # Changes:
    # 1. `gcc-5` -> `gcc`
    # 2. remove all `-std` flags

    gcc -c -fPIC -xc ./WDL/libpng/*.c
    gcc -c -fPIC -xc ./WDL/jpeglib/*.c
    gcc -c -fPIC -xc ./WDL/zlib/*.c
    gcc -c -fPIC -xc ./kuba/*.c
    g++ -c -fPIC -DSWELL_PROVIDED_BY_APP "./WDL/swell/swell-modstub-generic.cpp" "./WDL/lice/lice_png.cpp" "./WDL/lice/lice_png_write.cpp" "./WDL/lice/lice_jpg.cpp" "./WDL/lice/lice_jpg_write.cpp" "./WDL/lice/lice_colorspace.cpp" "./WDL/lice/lice.cpp"
    g++ -fPIC -shared -Wall -Wl,--no-undefined -DSWELL_PROVIDED_BY_APP -I"./WDL/swell/" -I"./WDL/jpeglib/" -I"./WDL/lice/" -I"./WDL/libpng/" -I"./WDL/zlib/" -I"./kuba/" js_ReaScriptAPI.cpp *.o `pkg-config --cflags --libs gtk+-3.0` -ldl -o reaper_js_ReaScriptAPI64.so

    # ====================================

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/UserPlugins
    install -Dm755 reaper_js_ReaScriptAPI64.so $out/UserPlugins

    cp ${dll} $out/UserPlugins/reaper_js_ReaScriptAPI64.dll

    runHook postInstall
  '';
}
