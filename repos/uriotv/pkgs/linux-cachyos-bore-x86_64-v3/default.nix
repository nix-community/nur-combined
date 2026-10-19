# Upstream files in ./upstream retain their GPL-2.0 license (see its LICENSE).
# Only this derivation is selected; no other CPU/scheduler/LTO variants are built.
{ callPackage, fetchFromGitHub, ... }@args:
let
  source = builtins.fromJSON (builtins.readFile ./upstream/source.json);
  upstream = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nix-cachyos-kernel";
    inherit (source) rev hash;
  };
  kernels = callPackage ./upstream/kernel-cachyos { };
in
# NixOS calls kernel.override with features/config/patches. Forward these rather
# than losing buildLinux's override API at the outer callPackage boundary.
(kernels.linux-cachyos-bore-x86_64-v3.override
  (builtins.removeAttrs args [ "callPackage" "fetchFromGitHub" ])).overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    # Publish the exact GPL build definitions alongside the patched kernel source.
    urioUpstreamSource = upstream;
  };
})
