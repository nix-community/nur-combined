{
  sources,

  lib,
  stdenv,

  cmake,
  cpm-cmake,
  git,
  juceCmakeHook,
  ninja,
  pkg-config,
}:
let
  date = lib.splitString "-" sources.sapphire-plugins.date;
in
stdenv.mkDerivation {
  inherit (sources.sapphire-plugins) pname src;
  version = sources.sapphire-plugins.date;

  nativeBuildInputs = [
    cmake
    git
    ninja
    pkg-config
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  cmakeFlags = [
    "-DVST3_SDK_ROOT=${sources.vst3sdk.src}"
    "-DGIT_COMMIT_HASH=${sources.sapphire-plugins.src.rev}"
    "-DCOPY_AFTER_BUILD=FALSE"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cp Sapphire.clap $out/lib/clap
    cp -r Release/Sapphire.vst3 $out/lib/vst3

    runHook postInstall
  '';

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "%j" ${builtins.toString ((lib.toIntBase10 (builtins.elemAt date 1)) * 2)} \
      --replace-fail "%Y" ${builtins.toString ((lib.toInt (builtins.elemAt date 0)) + 2021)}

    ln -sf ${cpm-cmake}/share/cpm/CPM.cmake libs/clap-libs/clap-wrapper/cmake/external/CPM.cmake
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Taking the wonders of Don Cross' Sapphire plugins into the clap-first/daw world";
    homepage = "https://github.com/baconpaul/sapphire-plugins";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
