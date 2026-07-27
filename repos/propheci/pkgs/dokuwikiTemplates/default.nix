{ pkgs }: {
    bootstrap3 = pkgs.callPackage ./bootstrap3.nix {};
    material = pkgs.callPackage ./material.nix {};
}
