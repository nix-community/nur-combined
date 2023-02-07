{ self }:
let inherit (self.inputs) stable unstable darwin-stable darwin-unstable;
in {
  # Note that this does not mean a system that utilises unstable-system
  # is purely unstable, it can utilise stable package-sets for home-manager 
  # and/or remaining system config, this only governs the generation of
  # system configs via either the current unstable or stable.
  stable-system = stable.lib.nixosSystem;
  unstable-system = unstable.lib.nixosSystem;

  # Darwin binds also
  stable-darwin-system = darwin-stable.lib.darwinSystem;
  unstable-darwin-system = darwin-unstable.lib.darwinSystem;
}
