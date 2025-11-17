{
  cargo-c,
  cargo,
  cmake,
  cmrt,
  fetchFromGitHub,
  ffmpeg,
  git,
  hdr10plus,
  intel-media-driver,
  lib,
  libass,
  libdovi,
  libdrm,
  libva,
  libvpl,
  makeWrapper,
  nix-update-script,
  ocl-icd,
  opencl-headers,
  pkg-config,
  stdenv,
  vpl-gpu-rt,
  wget,
  intel-compute-runtime,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qsvenc";
  version = "8.03";

  hardeningDisable = [ "all" ];

  src = fetchFromGitHub {
    owner = "rigaya";
    repo = "QSVEnc";
    tag = finalAttrs.version;
    hash = "sha256-enQKGwj31xylhYzOkkHzwM6BVizVP6/HHBHIseDrAkE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    cargo-c
    git
    wget
    makeWrapper
  ];

  buildInputs = [
    # libs
    libva
    libdrm
    ffmpeg # libavcodec, libavformat, etc
    libass
    libvpl
    opencl-headers
    ocl-icd
    libdovi
    cargo
    hdr10plus

    # intel
    intel-media-driver
    intel-compute-runtime
    vpl-gpu-rt
    cmrt
  ];

  postPatch = ''
    # Fix OpenCL 2.0+ compatibility
    substituteInPlace QSVPipeline/rgy_opencl.cpp \
      --replace 'img_desc.mem_object' 'img_desc.buffer'
  '';

  configurePhase = ''
    runHook preConfigure

    patchShebangs ./configure

    # Use CXX for linking instead of ld
    export LD="$CXX"

    ./configure --enable-debug

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v qsvencc $out/bin/

    # Wrap the binary to set necessary environment variables for Intel media drivers
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


    runHook postInstall
  '';

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "${finalAttrs.pname}"
      ];
    });
  };

  meta = {
    homepage = "https://github.com/rigaya/QSVEnc";
    mainProgram = "qsvencc";
    changelog = "https://github.com/rigaya/QSVEnc/releases/tag/${finalAttrs.src.tag}";
    description = "QSV high-speed encoding performance experiment tool";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
