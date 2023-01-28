self: super: {
  lib = super.lib.extend (import ../lib/overlay.nix);
}
