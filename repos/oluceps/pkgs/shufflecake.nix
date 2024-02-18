{ lib, kernel, stdenv, fetchFromGitea, libgcrypt, lvm2 }:
let
  genShufflecake = name: installPhase:
    stdenv.mkDerivation (finalAttrs: {
      inherit name;
      version = "0.4.4";
      src = fetchFromGitea {
        domain = "codeberg.org";
        owner = "shufflecake";
        repo = "shufflecake-c";
        rev = "v${finalAttrs.version}";
        hash = "sha256-zvGHM5kajJlROI8vg1yZQ5NvJvuGLV2iKvumdW8aglA=";
      };

      nativeBuildInputs = kernel.moduleBuildDependencies;
      buildInputs = [ libgcrypt lvm2 ];
      makeFlags = kernel.makeFlags ++ [
        "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];
      inherit installPhase;

      meta = with lib; {
        description = "A plausible deniability (hidden storage) layer for Linux";
        homepage = "https://shufflecake.net";
        license = licenses.gpl2Only;
        maintainers = with maintainers; [ oluceps ];
        platforms = platforms.linux;
      };
    });

in
(builtins.mapAttrs (name: value: genShufflecake name value) {
  kernelModule = "install -D dm-sflc.ko $out/lib/modules/${kernel.modDirVersion}/drivers/md/dm-sflc.ko";
  userland = "install -D shufflecake $out/bin/shufflecake";
})
