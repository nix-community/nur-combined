{
  callPackage,
  hyprlandPlugins,
}: {
  hypr-kinetic-scroll = callPackage ./hypr-kinetic-scroll.nix {inherit (hyprlandPlugins) mkHyprlandPlugin;};
}
