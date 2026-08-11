{
  boot = {
    loader.systemd-boot.enable = true;
    # Allow systemd-boot to modify EFI variables (required for boot entry management)
    loader.efi.canTouchEfiVariables = true;
  };
}
