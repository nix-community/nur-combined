{ pkgs ? import <nixpkgs> {} }:

let
  zig_0_10_0 = pkgs.zig.overrideAttrs (final: prev:
    {
      version = "0.10.0";
      src = pkgs.fetchFromGitHub {
        owner = "ziglang";
        repo = prev.pname;
        rev = final.version;
        sha256 = "sha256-DNs937N7PLQimuM2anya4npYXcj6cyH+dRS7AiOX7tw=";
      };
    }
  );
in

{
  zig-master = pkgs.callPackage ./zig-master { llvmPackages = pkgs.llvmPackages_15; };
  lorien = pkgs.callPackage ./lorien {};
  waylock = pkgs.callPackage ./waylock { zig = zig_0_10_0; };
  i3bar-river = pkgs.callPackage ./i3bar-river {};
  levee = pkgs.callPackage ./levee { zig = zig_0_10_0; };
  kickoff = pkgs.callPackage ./kickoff {};
  wired-notify = pkgs.callPackage ./wired-notify {};
  swayimg = pkgs.callPackage ./swayimg {};
}
