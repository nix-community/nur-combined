{ lib, newScope, stdenv, allegro5 }: let
    inherit (stdenv.hostPlatform) isDarwin;
    # PNG32 workaround for SimonN/LixD#431 is no longer needed after liballeg/allegro5#1653.
    allegro5HasNativeMacOSImageLoader = isDarwin && lib.versionOlder (lib.getVersion allegro5) "5.2.10.1-unstable-2025-07-19";
in lib.makeScope newScope (self: let inherit (self) callPackage; in {
    lix-game-packages = self;
    
    game = callPackage ./. {};
    game-unwrapped = callPackage ./unwrapped.nix {};
    assets = callPackage ./assets.nix {};
    music = callPackage ./music.nix {};
    server = callPackage ./server.nix {};
    
    common = callPackage ./common.nix {};
    highResTitleScreen = callPackage ./highResTitleScreen.nix {};
    
    convertImagesToTrueColor = allegro5HasNativeMacOSImageLoader;
    disableNativeImageLoader = allegro5HasNativeMacOSImageLoader && !self.convertImagesToTrueColor;
    useHighResTitleScreen = false;
    includeMusic = true;
})
