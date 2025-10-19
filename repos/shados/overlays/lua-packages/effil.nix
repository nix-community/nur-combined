{
  lib,
  stdenv,
  buildLuarocksPackage,
  fetchFromGitHub,
  gcc9,
}:

buildLuarocksPackage rec {
  pname = "effil";
  version = "1.2-0";

  # version = "unstable-2018-11-14";
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "0rij3ms8glzmr8j7b5607qwyhbcjy66i8wrw85bshixb32cn06wz";
    # Need the below for the 'sol' submodule especially; might want to look
    # into using system version?
    fetchSubmodules = true;
  };
  knownRockspec = "rockspecs/${pname}-${version}.rockspec";
  preConfigure = ''
    # Annoyingly, they're missing a rockspec for the latest version, despite tagging the commit?
    cp rockspecs/${pname}-1.1-0.rockspec "''${knownRockspec}"
    substituteInPlace ''${knownRockspec} \
      --replace '1.1-0' "$version"
  '';
  postConfigure = ''
    # We already have the submodule, we don't need fetch-gitrec
    substituteInPlace ''${rockspecFilename} \
      --replace ', "luarocks-fetch-gitrec"' '''
  '';
  nativeBuildInputs = [
    # Fails to compile on >=gcc10 due to sol2 issue #1001
    gcc9
  ];

  meta = with lib; {
    description = "Effil is a lua module for multithreading support, it allows you to spawn native threads and perform safe data exchange between them";
    homepage = "https://github.com/effil/effil";
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = with licenses; mit;
  };
}
