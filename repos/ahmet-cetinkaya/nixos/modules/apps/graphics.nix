{ pkgs, ... }: {
  # Flatpak
  services.flatpak.packages = [
    # 3D Modeling
    "org.blender.Blender"
    "org.freecad.FreeCAD"
    "org.openscad.OpenSCAD"
    "io.github.nokse22.Exhibit"

    # 3D Printing
    "com.orcaslicer.OrcaSlicer"

    # Video Editing
    "org.kde.kdenlive"

    # Photo Editing
    "org.inkscape.Inkscape"
    "org.upscayl.Upscayl"
  ];

  # Natively packaged: prebuilt upstream binary with dlopen'ed GPU/windowing
  # libs handled by the wrapper in pkgs/craft-apps/builder.nix.
  environment.systemPackages = [pkgs.photocraft-bin];
}
