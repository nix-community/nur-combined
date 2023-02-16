{ self }: {
  cli = import ./cli.nix { inherit self; };
  minimal-cli = import ./minimal-cli.nix { inherit self; };
  # Desktop shares modules with both linux and darwin
  desktop = import ./desktop.nix { inherit self; };

  # Both inherit from desktop, then add system specific packages on-top
  linux-desktop = import ./linux-desktop.nix { inherit self; };
  darwin-desktop = import ./darwin-desktop.nix { inherit self; };
}
