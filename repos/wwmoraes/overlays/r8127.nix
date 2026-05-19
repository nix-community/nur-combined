final: prev: {
  linuxPackages = prev.linuxPackages.extend (
    final: prev: {
      r8127 = prev.callPackage ../pkgs/r8127.nix { };
    }
  );
}
