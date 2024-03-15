{
  version,
  src,
  settingsSha256,
  settingsVersion,
  persistencedSha256,
  persistencedVersion,
  patches ? [ ],
  ...
}:
{
  lib,
  stdenv,
  callPackage,
  pkgs,
  kernel,
  perl,
  nukeReferences,
  which,
  ...
}:
with lib;
let
  nameSuffix = "-${kernel.version}";

  libPathFor =
    pkgs:
    lib.makeLibraryPath (
      with pkgs;
      [
        libdrm
        xorg.libXext
        xorg.libX11
        xorg.libXv
        xorg.libXrandr
        xorg.libxcb
        zlib
        stdenv.cc.cc
        wayland
        mesa
        libGL
      ]
    );

  self = stdenv.mkDerivation {
    name = "nvidia-x11-${version}${nameSuffix}";

    builder = ./vgpu-builder.sh;

    inherit version src;
    inherit (stdenv.hostPlatform) system;
    inherit patches;

    outputs = [
      "out"
      "bin"
    ];
    outputDev = "bin";

    kernel = kernel.dev;
    kernelVersion = kernel.modDirVersion;

    makeFlags = kernel.makeFlags ++ [
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

    buildInputs = [ which ];
    nativeBuildInputs = [
      perl
      nukeReferences
    ] ++ kernel.moduleBuildDependencies;

    disallowedReferences = [ kernel.dev ];

    passthru = {
      settings = callPackage (import ./settings.nix settingsSha256) { nvidia_x11 = self; };
      persistenced = callPackage (import ./persistenced.nix persistencedSha256) { nvidia_x11 = self; };
      inherit persistencedVersion settingsVersion;
      compressFirmware = false;
    };

    meta = with lib; {
      homepage = "https://www.nvidia.com/object/unix.html";
      description = "NVIDIA vGPU host driver (vGPU-KVM driver, experimental package)";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
    };
  };
in
self
