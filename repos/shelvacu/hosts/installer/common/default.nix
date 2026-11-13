{ config, lib, ... }: {
  imports = [ ./ssh.nix ];

  # this is an installer image, created anew every time. There's no state we need to worry about messing up
  system.stateVersion = config.system.nixos.release;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  vacu.hostName = "vacuInstaller";
  vacu.shell.color = "red";
  vacu.systemKind = "minimal";

  # The ISO already gets firmware from installation-cd-base, but netboot-minimal turns it off
  # with mkOverride 70, hence the mkForce.
  hardware.enableRedistributableFirmware = lib.mkForce true;
  # Early-load current microcode; shipped BIOSes are often years behind (and ancient revisions taint the kernel).
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  # Trade power saving for robustness: the installer runs briefly, usually on mains power, on
  # arbitrary hardware. None of these carry over to the installed system; set them per-host there
  # if the hardware needs them.
  boot.kernelParams = [
    # Deep C-states hard-freeze some CPUs (notably Jasper Lake N5095/N5105, e.g. the AZW G2).
    # intel_idle covers most Intel CPUs; processor.* covers anything on acpi_idle instead.
    "intel_idle.max_cstate=1"
    "processor.max_cstate=1"
    # Intel iGPU display power states (DC5/DC6) also freeze Jasper/Gemini Lake once DMC firmware loads.
    "i915.enable_dc=0"
    # Panel Self Refresh: flicker/garbage/frozen display on many Intel laptop panels.
    "i915.enable_psr=0"
    # Scatter-gather display: garbage-then-hang on some Ryzen APUs.
    "amdgpu.sg_display=0"
    # NVMe APST: "nvme controller is down; will reset" dropouts on some SSDs, worst mid-install.
    "nvme_core.default_ps_max_latency_us=0"
    # PCIe link power management: wifi/NIC/NVMe link drops on buggy boards.
    "pcie_aspm=off"
    # USB autosuspend: flaky USB NICs/hubs/keyboards (and the boot stick) dropping off.
    "usbcore.autosuspend=-1"
  ];

  vacu.packages = ''
    # keep-sorted start
    acpi
    aircrack-ng
    borgbackup
    dmidecode
    home-manager
    iio-sensor-proxy
    man
    mercurial
    nix-index
    nix-inspect
    nix-search-cli
    nmap
    nvme-cli
    rclone
    smartmontools
    tcpdump
    termscp
    # keep-sorted end
  '';
}
