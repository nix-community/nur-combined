{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.hardware.framework-desktop-amd-ai-max-300-series;
in

{
  options.abszero.hardware.framework-desktop-amd-ai-max-300-series.enable = mkEnableOption ''
    Framework desktop AMD Ryzen AI Max 300 series configuration complementary to
    `inputs.nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series`. Due to the
    nixos-hardware module being effective on import, it's not imported by this module; you have to
    import them yourself
  '';

  config = mkIf cfg.enable {
    nixpkgs.config.rocmSupport = true;

    hardware = {
      bluetooth.enable = true;
      enableRedistributableFirmware = true;
    };

    boot.kernelParams = [
      # Raise available VRAM to 124GiB (1/2)
      # Raise the size limit of the Graphics Translation Table to 124GiB
      "amdgpu.gttsize=126976"
      # Raise available VRAM to 124GiB (2/2)
      # Raise the pages limit of the Translation Table Manager to 124GiB
      "ttm.pages_limit=32505856"
      # Remove allocation churn when memory gets mapped/unmapped
      # Cap the pool of pre-allocated pages to 124GiB
      "ttm.page_pool_size=32505856"
      # Remove mapping overhead
      # Disable remapping the DMA through IOMMU page tables
      "amd_iommu=off"
    ];

    services.fwupd.enable = true;
  };
}
