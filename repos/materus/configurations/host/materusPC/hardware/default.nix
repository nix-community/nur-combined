{ config, pkgs, lib, inputs, materusFlake, materusPkgs, ... }:
let 
pkg = import  (builtins.fetchTarball {
  name = "nixos-23.05";
  url = "https://github.com/nixos/nixpkgs/archive/4ecab3273592f27479a583fb6d975d4aba3486fe.tar.gz";
  sha256 = "sha256:10wn0l08j9lgqcw8177nh2ljrnxdrpri7bp0g7nvrsn9rkawvlbf";
}) {system = pkgs.system;};
in
{
  imports =
    [
      ./filesystem.nix
      ./boot.nix

    ];
  hardware.firmware = with pkgs; [
    materusPkgs.amdgpu-pro-libs.firmware.vcn
    #materusPkgs.amdgpu-pro-libs.firmware
    linux-firmware
    alsa-firmware
    sof-firmware
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkForce true;

  #extra
  hardware.wooting.enable = true;
  hardware.bluetooth.enable = true;


  #Graphics
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
    materusPkgs.amdgpu-pro-libs.vulkan
    materusPkgs.amdgpu-pro-libs.amf
  ];
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    vaapiVdpau
    pkgs.driversi686Linux.amdvlk
    materusPkgs.i686Linux.amdgpu-pro-libs.vulkan
    libvdpau-va-gl
  ];
  users.groups.gpurun = {};
  services.udev.extraRules = ''

    #GPU bar size
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x744c", ATTR{resource0_resize}="15"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x744c", ATTR{resource2_resize}="8"
  '';
  

  #Trim
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

}
