{
  imports = [
    # ./buildkit.nix # sourced in flake direclty
    ./libvirt.nix
    # Containerd is now a module upstream
    # FIXME: remove this when 21.05 is out.
    ./containerd.nix
  ];
}
