# Hands each listed GPU an edited VBIOS when the NVIDIA open driver starts, in
# memory only; the flash chip is never written. The open modules are patched
# by the Vix loader, which supports R615 and later and refuses driver sources
# it has not reviewed. Ada and Ampere images must be relocated with Vix Editor
# to fit GSP's 512 KiB limit; see
# https://github.com/Panchovix/nvidia-linux-vbios-vix-loader.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.hardware.nvidia-vbios-override;
  nvidia = config.hardware.nvidia.package;
  isPciAddress =
    address: builtins.match "[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-7]" address != null;
  firmwareName = address: "${nvidia.version}/vbios-override/${address}.bin";
  forEachImage = f: lib.concatStrings (lib.mapAttrsToList f cfg.images);

  open = nvidia.open.overrideAttrs (old: {
    src = pkgs.runCommand "${old.src.name}-vbios-override" { } ''
      ${lib.getExe cfg.package} driver prepare --source ${old.src} --destination $out > /dev/null
    '';
  });

  firmware = pkgs.runCommand "nvidia-vbios-override-firmware" { } (
    forEachImage (
      address: image: ''
        install -Dm444 ${image} "$out/lib/firmware/nvidia/${firmwareName address}"
      ''
    )
  );

  # Registry keys read by the patched module. The declared size must match the
  # image exactly, so it is taken from the file at build time.
  modprobeConfig = pkgs.runCommand "nvidia-vbios-override.conf" { } ''
    dwords=() files=()
    ${forEachImage (
      address: image: ''
        dwords+=("pci=${address};RmLinuxVbiosOverride=2;RmLinuxVbiosOverrideSize=$(stat -c %s ${image})")
        files+=("pci=${address};RmLinuxVbiosOverrideImage=${firmwareName address}")
      ''
    )}
    IFS=';'
    echo "options nvidia NVreg_RegistryDwords=\"RmLinuxVbiosOverrideDisable=0\" NVreg_RegistryDwordsPerDevice=\"''${dwords[*]}\" NVreg_RegistryBinaryFilePerDevice=\"''${files[*]}\"" > $out
  '';
in
{
  options.hardware.nvidia-vbios-override = {
    enable = mkEnableOption "per-GPU VBIOS override through the patched NVIDIA open driver";

    images = mkOption {
      type = types.attrsOf types.path;
      example = lib.literalExpression ''{ "0000:01:00.0" = ./gpu0-loader.bin; }'';
      description = ''
        Override payload for each GPU, keyed by its full PCI address (as printed
        by `lspci -D`). Each payload must hold exactly one legacy image for that
        GPU; other GPUs keep their own VBIOS.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/nvidia-linux-vbios-vix-loader { };
      defaultText = lib.literalExpression "pkgs.callPackage <nur-packages/pkgs/nvidia-linux-vbios-vix-loader> { }";
      description = "The Vix loader used to patch the driver's open kernel modules.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hardware.nvidia.open;
        message = "hardware.nvidia-vbios-override patches the open kernel modules; set hardware.nvidia.open = true.";
      }
      {
        assertion = cfg.images != { } && lib.all isPciAddress (builtins.attrNames cfg.images);
        message = "hardware.nvidia-vbios-override.images needs at least one entry keyed by a full PCI address such as 0000:01:00.0.";
      }
      {
        # The module sets these parameters itself; another value would replace
        # its settings or send the image to GSP through the registry RPC.
        assertion =
          !(lib.hasInfix "NVreg_Registry" config.boot.extraModprobeConfig)
          && !(lib.any (lib.hasPrefix "nvidia.NVreg_Registry") config.boot.kernelParams);
        message = "hardware.nvidia-vbios-override owns the NVIDIA NVreg_Registry* parameters; remove other definitions.";
      }
    ];

    # Same package as the driver's own open modules, which this one shadows.
    boot.extraModulePackages = [ (lib.hiPrio open) ];
    hardware.firmware = [ firmware ];
    environment.etc."modprobe.d/nvidia-vbios-override.conf".source = modprobeConfig;
  };
}
