{ stdenv, gnumake, pkgconfig, fetchFromGitHub, which, perl, sqlite, ncurses, zlib
, enableTiles ? false, pngcrush ? null, libGLU ? null, libpng ? null, freetype ? null, SDL2 ? null, SDL2_image ? null, mesa_noglu ? null
, enableSound ? enableTiles, SDL2_mixer ? null }:

# TODO: needs some cleaning. Bones file is downloaded during install, so is
# missing if build in a sandbox.

assert enableSound -> enableTiles == true;
assert enableSound -> SDL2_mixer != null;

assert enableTiles -> SDL2 != null;
assert enableTiles -> SDL2_image != null;
assert enableTiles -> freetype != null;
assert enableTiles -> libGLU != null;
assert enableTiles -> libpng != null;
assert enableTiles -> mesa_noglu != null;
assert enableTiles -> pngcrush != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "crawl" + optionalString enableTiles "-tiles";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "crawl";
    repo = "crawl";
    rev = version;
    sha256 = "13z3cr87wdx3m43yi31aja441zflyxmvd59hr10x8j9lrr7c8cg6";
    fetchSubmodules = true;
  };

  # Force compiler, as it doesn't compile otherwise
  FORCE_CXX="g++";
  FORCE_CC="gcc";

  prePatch = ''
    for i in crawl-ref/source/util/*; do
      if [ -f $i ]
      then
        substituteInPlace $i --replace "/usr/bin/env perl" "${perl}/bin/perl"
      fi
    done
  '';

  enableParallelBuilding=true;

  TILES = optionalString enableTiles "yes";
  SOUND = optionalString enableSound "yes";

  preBuild = ''
    cd crawl-ref/source
    echo "${version}" > util/release_ver
  '';

  nativeBuildInputs = [
    gnumake
    pkgconfig
    which
  ] ++ optional enableTiles pngcrush;

  # TODO: figure out why some dependencies don't work, esp. luajit
  # currently use vendored libs instead
  buildInputs = [
    libpng
    ncurses
    perl
    sqlite
    zlib
  ] ++ optionals enableTiles [
    SDL2
    SDL2_image
    freetype
    libGLU
    mesa_noglu
  ] ++ optional enableSound SDL2_mixer;

  # crawl expects SDL2_image and SDL2_mixer in the same directory as SDL2, so we
  # need to specify them manually
  INCLUDES_L = "-I${zlib}/include"
    + optionalString enableTiles "-I${SDL2}/include -I${SDL2_image}/include"
    + optionalString enableSound " -I${SDL2_mixer}/include";
  SQLITE_INCLUDE_DIR = "${sqlite}/include";

  makeFlags = "prefix=$(out)";

  postInstall = optionalString enableTiles ''
      mv $out/bin/crawl $out/bin/crawl-tiles
    '';

  meta = with stdenv.lib; {
    description = "Dungeon Crawl: Stone Soup, a game of dungeon exploration, combat and magic, involving characters of diverse skills, worshipping deities of great power and caprice" + optionalString enableTiles " (graphical version)";
    homepage = https://crawl.develz.org/;
    license = with licenses; [ gpl2Plus ];
    maintainers = with maintainers; [ moredread ];
  };
}
