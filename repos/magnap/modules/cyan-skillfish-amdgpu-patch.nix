{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  cfg = config.hardware.cyan-skillfish;
  kernel = config.boot.kernelPackages.kernel;
  amdgpu-pkg = 
    pkgs.stdenv.mkDerivation {
      pname = "amdgpu-kernel-module";
      inherit (kernel) src version nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;

      modulePath = "drivers/gpu/drm/amd/amdgpu";

      postPatch = kernel.postPatch + ''
        substituteInPlace drivers/gpu/drm/amd/pm/swsmu/smu11/cyan_skillfish_ppt.c --replace-fail "CYAN_SKILLFISH_SCLK_MIN			1000" "CYAN_SKILLFISH_SCLK_MIN			350"
        substituteInPlace drivers/gpu/drm/amd/pm/swsmu/smu11/cyan_skillfish_ppt.c --replace-fail "CYAN_SKILLFISH_SCLK_MAX			2000" "CYAN_SKILLFISH_SCLK_MAX			2230"
        substituteInPlace drivers/gpu/drm/amd/pm/swsmu/smu11/cyan_skillfish_ppt.c --replace-fail "CYAN_SKILLFISH_VDDC_MIN			700" "CYAN_SKILLFISH_VDDC_MIN			550"
	patchShebangs scripts/bpf_doc.py
      '';

      buildPhase = ''
        BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

        cp $BUILT_KERNEL/Module.symvers .
        cp $BUILT_KERNEL/.config        .
        cp $kernel_dev/vmlinux          .

        make "-j$NIX_BUILD_CORES" modules_prepare
        make "-j$NIX_BUILD_CORES" M=$modulePath modules
      '';

      installPhase = ''
        make \
          INSTALL_MOD_PATH="$out" \
          XZ="xz -T$NIX_BUILD_CORES" \
          M="$modulePath" \
          modules_install
      '';

      meta = {
        description = "AMD GPU kernel module";
        license = lib.licenses.gpl3;
      };
    };
in
{
  options.hardware.cyan-skillfish = {
    patch-driver = mkEnableOption "amdgpu patch for increased frequency range";
  };

  config = {
    boot.extraModulePackages = mkIf cfg.patch-driver [ amdgpu-pkg ];
  };
}

