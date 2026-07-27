# External overlays from flake inputs
{ inputs, lib }:
lib.composeManyExtensions [
  inputs.neovim-nightly-overlay.overlays.default
  inputs.nix-cachyos-kernel.overlays.default
  inputs.nvfetcher.overlays.default
  inputs.llm-agents.overlays.default
]
