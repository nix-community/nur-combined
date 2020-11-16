self: super:
{
    nodePackages = super.nodePackages // import ./composition.nix {pkgs = super;};
}