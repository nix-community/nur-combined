{ inputs, ... }: {
  imports =
    [ (import "${inputs.nixpkgs}/nixos/modules/profiles/hardened.nix") ];
  environment.memoryAllocator.provider = "libc";
}
