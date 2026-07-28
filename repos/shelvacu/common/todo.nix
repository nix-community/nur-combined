{ lib, ... }: {
  imports = [
    # diffoscope build is borked
    { vacu.packages.diffoscope.enable = lib.mkForce false; }
  ];
}
