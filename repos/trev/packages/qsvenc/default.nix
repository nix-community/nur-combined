{
  cmake,
  cmrt,
  fetchFromGitHub,
  ffmpeg,
  hdr10plus,
  intel-compute-runtime,
  intel-media-driver,
  lib,
  libass,
  libdovi,
  libdrm,
  libva,
  libx11,
  makeWrapper,
  meson,
  ninja,
  nix-update-script,
  ocl-icd,
  opencl-headers,
  pkg-config,
  stdenv,
  vpl-gpu-rt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qsvenc";
  version = "8.21";

  hardeningDisable = [ "all" ];

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "QSVEnc";
    tag = finalAttrs.version;
    hash = "sha256-kVV83YLz8QSVDjJWdPa4prtu08RVVa8CTHHSGdKymwY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    makeWrapper
  ];

  # cmake is only used to build the bundled libvpl submodule; don't let its
  # setup hook hijack the configure phase from meson.
  dontUseCmakeConfigure = true;

  buildInputs = [
    # libs
    libva
    libdrm
    ffmpeg # libavcodec, libavformat, etc
    libass
    libx11
    opencl-headers
    ocl-icd
    libdovi
    hdr10plus

    # intel
    intel-media-driver
    intel-compute-runtime
    vpl-gpu-rt
    cmrt
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "run_command('git', 'describe', '--tags', '--abbrev=0', check: true).stdout().strip()" \
        "'${finalAttrs.version}'"
  '';

  mesonFlags = [
    (lib.mesonBool "enable_vapoursynth" false)
    (lib.mesonBool "enable_avisynth" false)
  ];

  postFixup = ''
    wrapProgram $out/bin/qsvencc \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
          libva
          libdrm
          ocl-icd
        ]
      }" \
      --set LIBVA_DRIVER_NAME iHD \
      --prefix LIBVA_DRIVERS_PATH : "${intel-media-driver}/lib/dri" \
      --prefix OCL_ICD_VENDORS : "${intel-compute-runtime}/etc/OpenCL/vendors"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "qsvencc";
    description = "QSV high-speed encoding performance experiment tool";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    homepage = "https://github.com/rigaya/QSVEnc";
    changelog = "https://github.com/rigaya/QSVEnc/releases/tag/${finalAttrs.src.tag}";
  };
})
