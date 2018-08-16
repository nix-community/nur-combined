{ stdenv, fetchFromGitHub, cmake, sfml, lua5_1, luabind, sparsehash }:

stdenv.mkDerivation rec {
  name = "openhexagon-${version}";
  version = "1.92b";
  srcs = [
      (fetchFromGitHub rec {
        owner = "SuperV1234";
        repo = "SSVOpenHexagon";
        name = repo;
        rev = "${version}";
        sha256 = "0k4sc9cx4p3niy7fcpx4vfkpy5l355avchqas27za1n24zrq3x1b";
        fetchSubmodules = true;
      })
      (fetchFromGitHub rec {
        owner = "SuperV1234";
        repo = "SSVOpenHexagonAssets";
        name = repo;
        rev = "1d125de695be2e74c9f2ad3198e8b5b29911d010";
        sha256 = "02kwgvh3map24aqvd7crcb5vw6b3z11iv22sk58jc1qp7m24zfn4";
      })
    ];
  sourceRoot = "SSVOpenHexagon";
  unpackCmd = ''
    srcName=$(basename $(stripHash $curSrc))
    cp -r $curSrc ./$srcName
  '';
  postUnpack = "cp -r SSVOpenHexagonAssets/_RELEASE SSVOpenHexagon/";
  patchPhase = ''
    substituteInPlace \
      extlibs/SSVLuaWrapper/include/SSVLuaWrapper/LuaContext/LuaContext.h \
      --replace "lua5.1/" ""
  '';
  nativeBuildInputs = [ cmake stdenv ];
  buildInputs = [ sfml lua5_1 luabind sparsehash ];
  configurePhase = ''
    pushd extlibs/SSVJsonCpp; cmake .; make; popd
    pushd extlibs/SSVUtils; cmake .; make; popd
    pushd extlibs/SSVUtilsJson; cmake . -DSSVJSONCPP_ROOT=../SSVJsonCpp -DSSVUTILS_ROOT=../SSVUtils; make; popd
    pushd extlibs/SSVStart; cmake .; make; popd
    pushd extlibs/SSVEntitySystem; cmake .; make; popd
    pushd extlibs/SSVMenuSystem; cmake .; make; popd
    pushd extlibs/SSVLuaWrapper; cmake . -DLUA_INCLUDE_DIR=${lua5_1}/include; make; popd
    cmake . \
      -DLUA_INCLUDE_DIR=${lua5_1}/include \
      -DSSVJSONCPP_ROOT=extlibs/SSVJsonCpp \
      -DSSVUTILS_ROOT=extlibs/SSVUtils \
      -DSSVSTART_ROOT=extlibs/SSVStart \
      -DSSVENTITYSYSTEM_ROOT=extlibs/SSVEntitySystem \
      -DSSVMENUSYSTEM_ROOT=extlibs/SSVMenuSystem \
      -DSSVLUAWRAPPER_ROOT=extlibs/SSVLuaWrapper
  '';
  installPhase = ''
    install -Dm755 SSVOpenHexagon $out/bin/SSVOpenHexagon
    # TODO, but I have to fix the segfault first
  '';
  meta.broken = true;
}
