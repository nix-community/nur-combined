{ pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    cargo-asm
    cargo-edit
    cargo-sort
    cargo-generate
    cargo-expand
    rustc
    rustfmt
    clippy
    rust-analyzer
    crate2nix
    sccache
  ];
}
