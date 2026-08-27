# Expose repository packages without the full NUR namespace.
# The reserved exports (lib, overlays, the module indexes) are neither derivations
# nor recursable package sets, so filtering by value drops them without a name list.
self: super:
super.lib.filterAttrs
(_: value: super.lib.isDerivation value || value ? recurseForDerivations)
(import ./default.nix {pkgs = super;})
