{ lib, newScope, maintainers, hostPlatform }: let
    inherit (hostPlatform) isDarwin;
in lib.makeScope newScope (self: let inherit (self) callPackage; in {
    lix-game-packages = self;
    
    game = callPackage ./wrapper.nix {};
    game-unwrapped = callPackage ./game.nix {};
    assets = callPackage ./assets.nix {};
    music = callPackage ./music.nix {};
    server = callPackage ./server.nix {};
    
    common = callPackage ./common.nix { inherit maintainers; };
    highResTitleScreen = callPackage ./highResTitleScreen.nix {};
    
    convertImagesToTrueColor = isDarwin;
    disableNativeImageLoader = isDarwin && !self.convertImagesToTrueColor;
    useHighResTitleScreen = false;
    includeMusic = true;
})
