{callPackage, ...}@args: callPackage ../. (args // {
    _xpenguins-unwrapped = callPackage ./unwrapped.nix {};
})
