{
  callPackage,
  hyprlandPlugins,
}: {
  hypr-kinetic-scroll = callPackage ./hypr-kinetic-scroll {inherit (hyprlandPlugins) mkHyprlandPlugin;};

  # Lua plugin does not use Hyprland's native plugin builder.
  hyprsplit = callPackage ./hyprsplit {};
}
