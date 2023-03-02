{ pkgs, ... }:
{ file }:
pkgs.runCommandLocal "rust-script" {
  inherit file;
  nativeBuildInputs = [ pkgs.rust-script ];
} ''
  mkdir $out
  cp -v -- $file main.rs
  rust-script --cargo-output --gen-pkg-only --pkg-path $out main.rs
''
