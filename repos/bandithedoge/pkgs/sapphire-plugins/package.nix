{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  cpm-cmake,
  git,
  juceCmakeHook,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sapphire-plugins";
  version = "Nightly-unstable-2025-01-27";
  src = fetchFromGitHub {
    owner = "baconpaul";
    repo = "sapphire-plugins";
    rev = "2aa07b6ffd6b92d3058efdb5ff7a57fb8d7f25e7";
    hash = "sha256-zobZXe+yM1UFAg4T1GqG7oUk/phYpxivBrX2eJwk6TE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    git
    ninja
    pkg-config
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  cmakeFlags = [
    "-DVST3_SDK_ROOT=${
      fetchFromGitHub {
        owner = "steinbergmedia";
        repo = "vst3sdk";
        rev = "v3.7.6_build_18";
        hash = "sha256-jfh+iP5rqov8q++IyG4FXlYKs4PQtFjCwCP6xou8N0E=";
        fetchSubmodules = true;
      }
    }"
    "-DGIT_COMMIT_HASH=${finalAttrs.src.rev}"
    "-DCOPY_AFTER_BUILD=FALSE"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cp Sapphire.clap $out/lib/clap
    cp -r Release/Sapphire.vst3 $out/lib/vst3

    runHook postInstall
  '';

  postPatch =
    let
      date = lib.splitString "-" finalAttrs.version;
    in
    ''
      substituteInPlace CMakeLists.txt \
        --replace-fail "%j" ${toString ((lib.toIntBase10 (builtins.elemAt date 3)) * 2)} \
        --replace-fail "%Y" ${toString ((lib.toInt (builtins.elemAt date 2)) + 2021)}

      ln -sf ${cpm-cmake}/share/cpm/CPM.cmake libs/clap-libs/clap-wrapper/cmake/external/CPM.cmake
    '';

  hardeningDisable = [ "format" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Taking the wonders of Don Cross' Sapphire plugins into the clap-first/daw world";
    homepage = "https://github.com/baconpaul/sapphire-plugins";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
