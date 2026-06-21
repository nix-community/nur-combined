{ pkgs, ... }: {
  # Flatpak
  services.flatpak.packages = [
    # 3D Modeling
    "org.blender.Blender"
    "org.freecad.FreeCAD"
    "org.openscad.OpenSCAD"
    "io.github.nokse22.Exhibit"

    # 3D Printing
    "io.github.softfever.OrcaSlicer"

    # Video Editing
    "org.kde.kdenlive"

    # Photo Editing
    "org.inkscape.Inkscape"
    "org.upscayl.Upscayl"
  ];
}
