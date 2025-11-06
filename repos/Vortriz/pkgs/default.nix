pkgs: let
    inherit (pkgs) callPackage;
    callPackage' = pkg: pkgs.callPackage pkg {sources = pkgs.callPackage ../_sources/generated.nix {};};
in {
    dunefetch-git = callPackage' ./dunefetch/package.nix;
    goldfish-git = callPackage' ./goldfish/package.nix;
    xdg-desktop-portal-termfilechooser-git = callPackage' ./xdg-desktop-portal-termfilechooser/package.nix;

    # Fonts
    HelveticaNeueCyr = callPackage ./fonts/HelveticaNeueCyr.nix {};
    SFMono = callPackage ./fonts/SFMono.nix {};
}
