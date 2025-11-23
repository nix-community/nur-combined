{ lib, newScope, fpc }: let
in lib.makeScope newScope (self: let inherit (self) callPackage; in {
    inherit fpc;
    
    drl-packages = self;
    
    drl-hq = callPackage ./. { drl-audio = self.drl-audio-hq; };
    drl-lq = callPackage ./. { drl-audio = self.drl-audio-lq; };
    drl = self.drl-hq;
    drl-unwrapped = callPackage ./unwrapped.nix {};
    drl-audio-hq = callPackage ./audio.nix { audioQuality = "hq"; };
    drl-audio-lq = callPackage ./audio.nix { audioQuality = "lq"; };
    drl-audio = self.drl-audio-hq;
    drl-icon = callPackage ./icon.nix {};
    drl-common = callPackage ./common.nix {};
})
