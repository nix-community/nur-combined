{ stdenv, libpng, gnumake, pkgconfig, fetchFromGitHub, which, fetchgit, perl, git, sqlite, freetype, SDL2, SDL2_image, SDL2_mixer, mesa_noglu, ncurses, zlib, pngcrush, libGLU, enableTiles ? false, enableSound ? enableTiles }:

# TODO: needs some cleaning. Bones file is downloaded during install, so is
# missing if build in a sandbox. Needs deepClone atm as version string is
# generated from git commit (might be generated manually).

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "env";
  version = "0.22.1";

#  src = fetchFromGitHub {
#    owner = "crawl";
#    repo = "crawl";
#    rev = version;
#    sha256 = "13z3cr87wdx3m43yi31aja441zflyxmvd59hr10x8j9lrr7c8cg6";
#    fetchSubmodules = true;
#  };

  # Force compiler, as it doesn't compile otherwise
  FORCE_CXX="g++";
  FORCE_CC="gcc";

  src = fetchgit {
    url = "git://github.com/crawl/crawl.git";
    rev = version;
    sha256 = "1f8qkm3symph6pscsnmgngvfmicw37vj7zmn6r49scfrd546pd05";
    fetchSubmodules = true;
    leaveDotGit = true;
    deepClone = true;
  };

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
  '';

  nativeBuildInputs = [
    git
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
  INCLUDES_L = optionalString enableTiles "-I${SDL2} -I${SDL2_image}" + optionalString enableSound "-I${SDL2_mixer}";
  SQLITE_INCLUDE_DIR = "${sqlite}/include";
  BUILD_ZLIB = "yes";

  makeFlags = "prefix=$(out)";

  meta = with stdenv.lib; {
    description = "A game of dungeon exploration, combat and magic, involving characters of diverse skills, worshipping deities of great power and caprice" + optionalString enableTiles " (graphical version)";
    homepage = https://crawl.develz.org/;
    license = with licenses; [ gpl2Plus ];
    maintainers = with maintainers; [ moredread ];
  };
}
