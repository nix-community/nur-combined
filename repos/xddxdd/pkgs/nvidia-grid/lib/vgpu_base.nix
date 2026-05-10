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
  libarchive,
  jq,
  zstd,
  # Options
  useGLVND ? true,
  useProfiles ? true,
}:
let
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
  pname = "nvidia-x11-vgpu";

  builder = ./vgpu-builder.sh;

  inherit
    version
    src
    useGLVND
    useProfiles
    ;
  inherit
    patches
    prePatch
    patchFlags
    postPatch
    ;
  inherit preInstall postInstall;
  inherit (kernel.stdenv.hostPlatform) system;
  inherit i686bundled;

  outputs = [
    "out"
    "bin"
    "modsrc"
    "vgpuConfig"
  ]
  ++ lib.optional i686bundled "lib32";
  outputDev = "bin";

  dontStrip = true;
  dontPatchELF = true;

  libPath = libPathFor pkgs;
  libPath32 = lib.optionalString i686bundled (libPathFor pkgsi686Linux);

  nativeBuildInputs = [
    libarchive
    jq
    zstd
  ];

  passthru = {
    mod = callPackage ./kernel-modules.nix {
      inherit kernel;
      nvidia_x11 = finalAttrs.finalPackage;
    };
    settings = callPackage (import (
      pkgs.path + "/pkgs/os-specific/linux/nvidia-x11/settings.nix"
    ) finalAttrs.finalPackage settingsSha256) { };
    persistenced = callPackage (import (
      pkgs.path + "/pkgs/os-specific/linux/nvidia-x11/persistenced.nix"
    ) finalAttrs.finalPackage persistencedSha256) { };
    inherit persistencedVersion settingsVersion;
    compressFirmware = false;
  };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://www.nvidia.com/object/unix.html";
    description = "NVIDIA vGPU host driver (vGPU-KVM driver, experimental package)";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
})
