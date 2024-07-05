{ stdenv, lib, fetchFromGitHub, unstableGitUpdater, cmake, ninja }:
stdenv.mkDerivation rec {
  pname = "sdhlt";
  version = "1.1.2-unstable-2023-08-24";

  src = fetchFromGitHub {
    owner = "seedee";
    repo = "SDHLT";
    rev = "aec4c3c5e0dbaa2a739b0b6988686eea296ab17e";
    sha256 = "sha256-Q+K54t1gXI4RGjVBdxxBgsxKQ01gVW80L4ZMTywbYxw=";
  };

  nativeBuildInputs = [ cmake ninja ];

  enableParallelBuilding = true;

  passthru.updateScript = unstableGitUpdater;

  hardeningDisable = [ "format" ]; # otherwise building CMakeFiles/BSP.dir/src/sdhlt/common/log.cpp.o fails

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cd ..
    mv tools/* $out
    runHook postInstall
  '';

  meta = {
    homepage = "https://gamebanana.com/tools/6778";
    changelog = "https://github.com/seedee/SDHLT/tree/${src.rev}/CHANGELOG.md";
    description = "Map compile tools for the Half-Life engine, based on Vluzacn's ZHLT v34";
    license = with lib.licenses; [ gpl2 unfree ];
  };
}
