# discord gtk3 client
{ lib, pkgs, ... }:
{
  sane.programs.abaddon = {
    # nixpkgs marks this explicitly as x86_64-only.
    # but i can build it for aarch64 here.
    # the only x86_64 runtime dependency is gnum4, via gtkmm (likely unused; build remnant).
    # see upstream nixpkgs PR: <https://github.com/NixOS/nixpkgs/pull/268433>
    package = pkgs.abaddon.overrideAttrs (upstream: {
      meta = upstream.meta // {
        platforms = lib.platforms.linux;
      };
    });

    persist.byStore.private = [
      ".cache/abaddon"
      ".config/abaddon"  # empty?
    ];
  };
}
