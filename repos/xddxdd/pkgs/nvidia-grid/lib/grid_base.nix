{
  version,
  src,
  settingsSha256,
  settingsVersion,
  persistencedSha256,
  persistencedVersion,

  prePatch ? "",
  postPatch ? "",
  patchFlags ? null,
  patches ? [ ],
  preInstall ? "",
  postInstall ? "",
}:
{
  lib,
  callPackage,
  pkgs,
  pkgsi686Linux,
  kernel,
  perl,
  nukeReferences,
  which,
  libarchive,
  jq,
  # Options
  useGLVND ? true,
  useProfiles ? true,
}:
let
  nameSuffix = "-${kernel.version}";
  i686bundled = true;

  libPathFor =
    pkgs:
    lib.makeLibraryPath (
      with pkgs;
      [
        libdrm
        libxext
        libx11
        libxv
        libxrandr
        libxcb
        zlib
        stdenv.cc.cc
        wayland
        libgbm
        libGL
        openssl
        dbus # for nvidia-powerd
      ]
    );
in
kernel.stdenv.mkDerivation (finalAttrs: {
  name = "nvidia-x11-${version}${nameSuffix}";

  builder = ./grid-builder.sh;

  inherit
    version
    src
    useGLVND
    useProfiles
    ;
  inherit
    patches
    prePatch
    postPatch
    patchFlags
    ;
  inherit preInstall postInstall;
  inherit (kernel.stdenv.hostPlatform) system;
  inherit i686bundled;

  outputs = [
    "out"
    "bin"
  ]
  ++ lib.optional i686bundled "lib32";
  outputDev = "bin";

  kernel = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  makeFlags =
    (kernel.commonMakeFlags or kernel.makeFlags)
    ++ [
      "IGNORE_PREEMPT_RT_PRESENCE=1"
      "NV_BUILD_SUPPORTS_HMM=1"
      "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
      "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ]
    ++ lib.optionals kernel.stdenv.cc.isClang [
      "C_INCLUDE_PATH=${lib.getLib kernel.stdenv.cc.cc}/lib/clang/${lib.versions.major kernel.stdenv.cc.cc.version}/include"
    ];

  hardeningDisable = [
    "pic"
    "format"
  ];

  dontStrip = true;
  dontPatchELF = true;

  libPath = libPathFor pkgs;
  libPath32 = lib.optionalString i686bundled (libPathFor pkgsi686Linux);

  nativeBuildInputs = [
    perl
    nukeReferences
    which
    libarchive
    jq
  ]
  ++ kernel.moduleBuildDependencies;

  disallowedReferences = [ kernel.dev ];

  passthru = {
    settings = callPackage (import ./settings.nix settingsSha256) {
      nvidia_x11 = finalAttrs.finalPackage;
    };
    persistenced = callPackage (import ./persistenced.nix persistencedSha256) {
      nvidia_x11 = finalAttrs.finalPackage;
    };
    inherit persistencedVersion settingsVersion;
    compressFirmware = false;
  };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://www.nvidia.com/object/unix.html";
    description = "NVIDIA vGPU guest driver (GRID driver, experimental package)";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
})
