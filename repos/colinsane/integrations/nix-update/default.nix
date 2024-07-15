# this is the entry point for `nix-update`, used when i update the packages in this repo.
# nix-update needs to work on the actual out-of-store source,
# which means it can't call through the hermetic `default.nix` at the top of this repo,
# but rather needs the in-place `impure.nix` entry point.
import ../../impure.nix
