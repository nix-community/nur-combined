{ fetchFromGitHub }: fetchFromGitHub {
    name = "nixpkgs-qemu9_1";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "a5c345b6d5e2d7d0e0a8c336a2bd6a0a42ea7623";
    sparseCheckout = [
        "pkgs/applications/virtualization/qemu"
    ];
    nonConeMode = true;
    hash = "sha256-D+TBNvo7uVkC4sRulA5obW3iRUPdxVTDYjr/rfhup2k=";
}
