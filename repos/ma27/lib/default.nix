{ callPackage }:

{
  ### HETZNER
  mkHetznerVm = import ./hetzner/make-hetzner-vm.nix;

  mkGrub = import ./hetzner/make-grub.nix;

  mkInitrd = import ./hetzner/make-initrd.nix;

  ### LaTeX setup
  mkTexDerivation = callPackage ./tex/make-tex-env.nix { };
}
