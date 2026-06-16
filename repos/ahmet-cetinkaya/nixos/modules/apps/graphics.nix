{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.nur.repos.forkprince.orca-slicer
  ];

  # Flatpak
  services.flatpak.packages = [
    # 3D Modeling
    "org.blender.Blender"
    "org.freecad.FreeCAD"
    "org.openscad.OpenSCAD"

    # Video Editing
    "org.kde.kdenlive"

    # Photo Editing
    "org.inkscape.Inkscape"
    "org.upscayl.Upscayl"
  ];
}
