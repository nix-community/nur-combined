{ ... }:
{
  imports = [
    ./aarch64.nix
    ./aarch64-musl.nix
    ./intel.nix
    ./musl.nix
    ./pine64-pinephone
    ./pine64-pinephone-pro
    ./rpi-400.nix
    ./samsung
    ./static.nix
    ./strict.nix
    ./x86_64.nix
    ./xiaomi-pocophone
  ];
}
