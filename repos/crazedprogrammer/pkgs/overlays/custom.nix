self: super:

{
  # Custom packages
  bobthefish = super.callPackage ../custom/bobthefish.nix {};
  riko4 = super.callPackage ../custom/riko4.nix {};
  luakit = super.callPackage ../custom/luakit.nix {};
  technic-launcher = super.callPackage ../custom/technic-launcher.nix {};
  thelounge = super.callPackage ../custom/thelounge.nix {};
  ls_extended = super.callPackage ../custom/ls_extended.nix {};
  kristvanity = super.callPackage ../custom/kristvanity.nix {};
  chip8 = super.callPackage ../custom/chip8.nix {};
  esp32-toolchain = super.callPackage ../custom/esp32-toolchain.nix {};
  compton-latest = super.callPackage ../custom/compton-latest.nix {};
  sway-session = super.callPackage ../custom/sway-session.nix {};
  kernel-gcc-patch = super.callPackage ../custom/kernel-gcc-patch.nix {};
}
