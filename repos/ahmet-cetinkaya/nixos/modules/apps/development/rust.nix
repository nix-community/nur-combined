{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cargo # Keep the Rust toolchain under Nix ownership; projects pin dependencies.
    rustc
    rustfmt
  ];
}
