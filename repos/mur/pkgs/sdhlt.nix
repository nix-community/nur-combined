{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  fetchpatch2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sdhlt";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "seedee";
    repo = "SDHLT";
    rev = "refs/tags/v${finalAttrs.version}";
    sha256 = "sha256-YI9R1sGdCGkYTRs0oWLxtgu01/Z9RXbAi32965f89zY=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ]; # otherwise building CMakeFiles/BSP.dir/src/sdhlt/common/log.cpp.o fails

  patches = [
    (fetchpatch2 {
      name = "add-platform-independent-stricmp.patch"; # fix building on linux: https://github.com/seedee/SDHLT/issues/13
      url = "https://github.com/seedee/SDHLT/commit/9b94e4fd1c4392802e1a01256596ea69894afc49.patch";
      hash = "sha256-j6rDO3uO6oVmCEaq3+6aYjwlV24eA4mr1FnNXMyYM8k=";
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt/sdhlt
    mv ../tools/* $out/opt/sdhlt
    runHook postInstall
  '';

  meta = {
    homepage = "https://gamebanana.com/tools/6778";
    changelog = "https://github.com/seedee/SDHLT/tree/${finalAttrs.src.rev}/CHANGELOG.md";
    description = "Map compile tools for the Half-Life engine, based on Vluzacn's ZHLT v34";
    license = with lib.licenses; [ gpl2 ]; # + unfree
  };
})
