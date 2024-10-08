{ lib, newScope, maintainers, stdenvNoCC }: let
    inherit (stdenvNoCC) isDarwin;
in lib.makeScope newScope (self: let inherit (self) callPackage; in {
    game = callPackage ./wrapper.nix {};
    game-unwrapped = callPackage ./game.nix {};
    assets = callPackage ./assets.nix {};
    music = callPackage ./music.nix {};
    server = callPackage ./server.nix {};
    
    common = callPackage ./common.nix { inherit maintainers; };
    highResTitleScreen = callPackage ./highResTitleScreen.nix {};
    
    convertImagesToTrueColor = isDarwin;
    disableNativeImageLoader = callPackage ({convertImagesToTrueColor}: isDarwin && !convertImagesToTrueColor) {};
    useHighResTitleScreen = false;
    includeMusic = true;
})
