{ stdenv, buildLuarocksPackage, fetchgit
}:

buildLuarocksPackage rec {
  pname = "effil";
  version = "1.0-0";

  # version = "unstable-2018-11-14";
  src = fetchgit {
    # owner = "effil"; repo = "effil";
    url = "https://github.com/effil/effil";
    rev = "73be7561235f5f472fce6ed3173dff08bbd14423";
    sha256 = "1zxvhv5zv68r5sr3imxv0pshss4lwxy54syg6cq6cklvkliaknvh";
    # Need the below for the 'sol' submodule especially; might want to look
    # into using system version?
    fetchSubmodules = true;
  };
  knownRockspec = "rockspecs/${pname}-${version}.rockspec";
  postConfigure = ''
    # We already have the submodule, we don't need fetch-gitrec
    substituteInPlace ''${rockspecFilename} \
      --replace ', "luarocks-fetch-gitrec"' '''

    # There's no more effil.lua, it's all in the shared object now
    sed ''${rockspecFilename} -i \
      -Ee '/lua = \{ install_dir /d' \
      -Ee 's|libeffil\.so|effil.so|g'
  '';

  meta = with stdenv.lib; {
    description = "Effil is a lua module for multithreading support, it allows you to spawn native threads and perform safe data exchange between them";
    homepage = https://github.com/effil/effil;
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = with licenses; mit;
  };
}
