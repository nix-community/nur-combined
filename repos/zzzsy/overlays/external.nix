# External overlays from flake inputs
{ inputs, lib }:
lib.composeManyExtensions [
  inputs.niri.overlays.default
  inputs.neovim-nightly-overlay.overlays.default
  inputs.nix-cachyos-kernel.overlays.pinned
  inputs.nvfetcher.overlays.default
  inputs.llm-agents.overlays.shared-nixpkgs
]
