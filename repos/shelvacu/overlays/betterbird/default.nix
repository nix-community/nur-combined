self: super: {
  betterbird-128-unwrapped = self.callPackage ./package.nix { };
  betterbird-128 = self.wrapThunderbird self.betterbird-128-unwrapped { };
}
