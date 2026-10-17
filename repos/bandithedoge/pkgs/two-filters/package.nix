{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  git,
  juceCmakeHook,
  ninja,
  pkg-config,
  rtaudio_6,
  rtmidi,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "two-filters";
  version = "Nightly-unstable-2026-10-15";
  src = fetchFromGitHub {
    owner = "baconpaul";
    repo = "two-filters";
    rev = "f6661927329a5cf1ce3dd6fd3db8d560d75903ac";
    hash = "sha256-MMd+r4B9DqoH/DNwDHBV2IdHfaZpIecpVzWua6YglKc=";
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
    "-DCOPY_AFTER_BUILD=FALSE"
    "-DGIT_COMMIT_HASH=${finalAttrs.src.rev}"
    "-DRTAUDIO_SDK_ROOT=${rtaudio_6.src}"
    "-DRTMIDI_SDK_ROOT=${rtmidi.src}"
    "-DVST3_SDK_ROOT=${
      fetchFromGitHub {
        owner = "steinbergmedia";
        repo = "vst3sdk";
        rev = "v3.7.6_build_18";
        hash = "sha256-jfh+iP5rqov8q++IyG4FXlYKs4PQtFjCwCP6xou8N0E=";
        fetchSubmodules = true;
      }
    }"
  ];

  hardeningDisable = [ "format" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/vst3}
    cp "two-filters_assets/Two Filters" $out/bin/TwoFilters
    cp "two-filters_assets/Two Filters.clap" $out/lib/clap
    cp -r "two-filters_assets/Two Filters.vst3" $out/lib/vst3

    runHook postInstall
  '';

  env.SOURCE_DATE_EPOCH =
    lib.toInt (lib.elemAt (lib.splitString "-" finalAttrs.version) 2) * 365 * 24 * 60 * 60;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Two Filters, Two Step Sequencers, and some fixed mod paths";
    homepage = "https://github.com/baconpaul/two-filters";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "TwoFilters";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
