self: super:

{
  fzf-nix-helpers = self.callPackage ./. { };
}
