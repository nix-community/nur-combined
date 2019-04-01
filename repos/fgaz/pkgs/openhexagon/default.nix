# Note: this packae tends to segfault without further output when it does not
# find all the data files it needs in the right places (or not writable),
# so be careful when editing

{ stdenv
, fetchurl
, fetchFromGitHub
, makeWrapper
, cmake
, sfml
, lua5_1
, luabind
, sparsehash }:

let
  cmakeFlags = "-DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=RELEASE";
  assetsVersion = "1.92";
  githubVersion = "1.92b";
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
  postUnpack = ''
    mv OpenHexagon${assetsVersion} OpenHexagonAssets
    cp -r OpenHexagonAssets/_DOCUMENTATION  SSVOpenHexagon/_RELEASE
    cp -r OpenHexagonAssets/config.json     SSVOpenHexagon/_RELEASE
    cp -r OpenHexagonAssets/Packs           SSVOpenHexagon/_RELEASE
    cp -r OpenHexagonAssets/Assets          SSVOpenHexagon/_RELEASE
    cp -r OpenHexagonAssets/ConfigOverrides SSVOpenHexagon/_RELEASE
    cp -r OpenHexagonAssets/Profiles        SSVOpenHexagon/_RELEASE
  '';
  patchPhase = ''
    substituteInPlace \
      extlibs/SSVLuaWrapper/include/SSVLuaWrapper/LuaContext/LuaContext.h \
      --replace "lua5.1/" ""
    sed -i -e s@/usr/local@\''${CMAKE_INSTALL_PREFIX}@g CMakeLists.txt
  '';
  nativeBuildInputs = [ cmake stdenv makeWrapper ];
  buildInputs = [ sfml lua5_1 luabind sparsehash ];
  configurePhase = ''
    pushd extlibs/SSVJsonCpp; cmake . ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVUtils; cmake . ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVUtilsJson; cmake . -DSSVJSONCPP_ROOT=../SSVJsonCpp -DSSVUTILS_ROOT=../SSVUtils ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVStart; cmake . ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVEntitySystem; cmake . ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVMenuSystem; cmake . ${cmakeFlags}; make; make install; popd
    pushd extlibs/SSVLuaWrapper; cmake . -DLUA_INCLUDE_DIR=${lua5_1}/include ${cmakeFlags}; make; make install; popd
    cmake . \
      -DLUA_INCLUDE_DIR=${lua5_1}/include \
      -DSSVJSONCPP_ROOT=extlibs/SSVJsonCpp \
      -DSSVUTILS_ROOT=extlibs/SSVUtils \
      -DSSVSTART_ROOT=extlibs/SSVStart \
      -DSSVENTITYSYSTEM_ROOT=extlibs/SSVEntitySystem \
      -DSSVMENUSYSTEM_ROOT=extlibs/SSVMenuSystem \
      -DSSVLUAWRAPPER_ROOT=extlibs/SSVLuaWrapper \
      ${cmakeFlags}
  '';
  preFixup = ''
    chmod +x $out/bin/SSVOpenHexagon
    wrapProgram $out/bin/SSVOpenHexagon \
      --prefix LD_LIBRARY_PATH : $out/lib \
      --run "cd $out/games/SSVOpenHexagon"
  '';
  # TODO find a way to make config, logs, and profiles writable
}

