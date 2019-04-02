# Note: this package tends to segfault without further output when it does not
# find all the data files it needs in the right places (or not writable),
# so be careful when editing

{ stdenv
, fetchurl
, fetchFromGitHub
, makeWrapper
, writeScript
, cmake
, sfml
, lua5_1
, luabind
, sparsehash
, extraPacks ? []
}:

let
  githubVersion = "1.92b";
  assetsVersion = "1.92";

  cmakeFlags =
    "-DCMAKE_INSTALL_PREFIX=$out " +
    "-DCMAKE_BUILD_TYPE=RELEASE " +
    # Not necessary for all libs, but it doesn't hurt
    "-DLUA_INCLUDE_DIR=${lua5_1}/include";

  # The vendored libraries to build and install before building the main
  # program. The order is important.
  extlibs = [
    "SSVJsonCpp"
    "SSVUtils"
    "SSVUtilsJson"
    "SSVStart"
    "SSVEntitySystem"
    "SSVMenuSystem"
    "SSVLuaWrapper"
  ];

  # See `preFixup` for why we do this
  symlinker = writeScript "openhexagon-symlinker" ''
    datadir="''${XDG_DATA_HOME:-''${HOME}/.local/share}/openhexagon"
    mkdir -p "''${datadir}"
    # Symlink only the STATIC assets
    for f in _DOCUMENTATION Assets ConfigOverrides; do
      rm -f "''${datadir}/''${f}" # Store paths can change with updates
      ln -s "''${1}/games/SSVOpenHexagon/''${f}" "''${datadir}/''${f}"
    done
    mkdir -p "''${datadir}/Packs"
    # Also symlink the default packs.
    # This is separate so the user can add other packs by copying them to the
    # user's Packs directory
    # TODO remove stale packs (not user packs though, not even symlinks!!)
    #        solution: pass them to the script
    for p in $(ls ''${1}/games/SSVOpenHexagon/Packs/); do
      rm -f "''${datadir}/Packs/''${p}" # Store paths can change with updates
      ln -s "''${1}/games/SSVOpenHexagon/Packs/''${p}" "''${datadir}/Packs/''${p}"
    done
    # Also copy the default config, but do not overwrite an existing one
    if [ ! -e "''${datadir}/config.json" ]; then
      cp "''${1}/games/SSVOpenHexagon/config.json" "''${datadir}/config.json"
      chmod u+w "''${datadir}/config.json"
    fi
  '';
in stdenv.mkDerivation rec {
  name = "openhexagon-${version}";
  version = githubVersion;
  srcs = [
      (fetchFromGitHub rec {
        owner = "SuperV1234";
        repo = "SSVOpenHexagon";
        name = repo;
        rev = "${version}";
        sha256 = "0k4sc9cx4p3niy7fcpx4vfkpy5l355avchqas27za1n24zrq3x1b";
        fetchSubmodules = true;
      })
      (fetchurl {
        url = "https://vittorioromeo.info/Downloads/OpenHexagon/Linux/OpenHexagonV${assetsVersion}.tar.gz";
        name = "SSVOpenHexagonAssets.tar.gz";
        sha256 = "0hs9hrl052b68c1icp8layl01d37kfbwn2s9qqnwf94lrx2fmcx3";
      })
    ];
  sourceRoot = "SSVOpenHexagon";

  # Copy the assets
  postUnpack = ''
    for f in _DOCUMENTATION config.json Packs Assets ConfigOverrides Profiles; do
      cp -r "OpenHexagon${assetsVersion}/''${f}"  "SSVOpenHexagon/_RELEASE/"
    done
  '';

  # Some paths are hardcoded/outdated
  patchPhase = ''
    substituteInPlace \
      extlibs/SSVLuaWrapper/include/SSVLuaWrapper/LuaContext/LuaContext.h \
      --replace "lua5.1/" ""
    substituteInPlace \
      CMakeLists.txt \
      --replace "/usr/local" "\''${CMAKE_INSTALL_PREFIX}"
  '';

  nativeBuildInputs = [ cmake stdenv makeWrapper ];
  buildInputs = [ sfml lua5_1 luabind sparsehash ];

  # The dependencies have to be built in advance, but are very difficult to
  # separate. So we just do everything in the install phase.
  configurePhase = ":";
  dontBuild = true;
  installPhase = ''
    for lib in ${toString extlibs}; do
      pushd "extlibs/''${lib}"
      cmake . ${cmakeFlags}
      make
      make install
      popd
    done
    cmake . ${cmakeFlags}
    make
    make install
    # Install the extra packs
    echo symlinking packs
    for pack in ${toString extraPacks}; do
      echo ln -s "''${pack}" "''${out}/games/SSVOpenHexagon/Packs/$(basename "''${pack}")"
      ln -s "''${pack}" "''${out}/games/SSVOpenHexagon/Packs/$(basename "''${pack}")"
    done
  '';

  # OpenHexagon looks in a few places for assets, none of which is $out.
  # One of those places is $PWD, but some files have to be writable
  # (the profile and the config file), so we symlink the STATIC assets in the
  # user's data directory and `cd` there.
  preFixup = ''
    chmod +x $out/bin/SSVOpenHexagon
    wrapProgram $out/bin/SSVOpenHexagon \
      --prefix LD_LIBRARY_PATH : $out/lib \
      --run "${symlinker} $out" \
      --run "cd \''${XDG_DATA_HOME:-\''${HOME}/.local/share}/openhexagon"
  '';
}

