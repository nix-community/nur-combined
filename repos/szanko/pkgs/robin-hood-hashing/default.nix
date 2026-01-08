{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "robin-hood-hashing";
  version = "3.11.5";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "robin-hood-hashing";
    rev = finalAttrs.version;
    hash = "sha256-J4u9Q6cXF0SLHbomP42AAn5LSKBYeVgTooOhqxOIpuM=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 "$src/src/include/robin_hood.h" "$out/include/robin_hood.h"
    runHook postInstall
  '';

  meta = {
    description = "Fast & memory efficient hashtable based on robin hood hashing for C++11/14/17/20";
    homepage = "https://github.com/martinus/robin-hood-hashing";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})
