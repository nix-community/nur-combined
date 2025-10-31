{
  version,
  src,
  settingsSha256,
  settingsVersion,
  persistencedSha256,
  persistencedVersion,
  patches ? [ ],
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
        gcc-unwrapped
        libdrm
        libGL
        mesa
        stdenv.cc.cc
        wayland
        xorg.libX11
        xorg.libxcb
        xorg.libXext
        xorg.libXrandr
        xorg.libXv
        zlib
      ]
    );

  self = kernel.stdenv.mkDerivation {
    name = "nvidia-x11-${version}${nameSuffix}";

    builder = ./grid-builder.sh;

    inherit
      version
      src
      useGLVND
      useProfiles
      ;
    inherit (kernel.stdenv.hostPlatform) system;
    inherit i686bundled;
    inherit patches;

    outputs = [
      "out"
      "bin"
    ]
    ++ lib.optional i686bundled "lib32";
    outputDev = "bin";

    kernel = kernel.dev;
    kernelVersion = kernel.modDirVersion;

    makeFlags = (kernel.commonMakeFlags or kernel.makeFlags) ++ [
      "IGNORE_PREEMPT_RT_PRESENCE=1"
      "NV_BUILD_SUPPORTS_HMM=1"
      "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
      "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    hardeningDisable = [
      "pic"
      "format"
    ];

    dontStrip = true;
    dontPatchELF = true;

    libPath = libPathFor pkgs;
    libPath32 = lib.optionalString i686bundled (libPathFor pkgsi686Linux);

    buildInputs = [ which ];
    nativeBuildInputs = [
      perl
      nukeReferences
      libarchive
    ]
    ++ kernel.moduleBuildDependencies;

    disallowedReferences = [ kernel.dev ];

    passthru = {
      settings = callPackage (import ./settings.nix settingsSha256) { nvidia_x11 = self; };
      persistenced = callPackage (import ./persistenced.nix persistencedSha256) { nvidia_x11 = self; };
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
  };
in
self
