{ fetchFromGitHub }: fetchFromGitHub {
    name = "nixpkgs-qemu7";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e88cc8f10e8913185830cce6d5895aae508498d1";
    sparseCheckout = [
        "pkgs/applications/virtualization/qemu"
    ];
    nonConeMode = true;
    hash = "sha256-Ee0uH+EBVk+ub+VFZbdCX+rArzSTP2RiX4B47jrsrWw=";
}
