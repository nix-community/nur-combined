# NUR (Nix User Repository) package exports
# See: https://nur.nix-community.org/documentation/
# Craft App Suite apps share pkgs/craft-apps/builder.nix.
{pkgs}: let
  craftBuilder = pkgs.callPackage ./craft-apps/builder.nix {};
in {
  antigravity-tools-bin = pkgs.callPackage ./antigravity-tools-bin {};
  dikte-bin = pkgs.callPackage ./dikte-bin {};

  # Craft Apps
  photocraft-bin = craftBuilder (import ./craft-apps/photocraft/default.nix);
  lightcraft-bin = craftBuilder (import ./craft-apps/lightcraft/default.nix);
  filmcraft-bin = craftBuilder (import ./craft-apps/filmcraft/default.nix);
  designcraft-bin = craftBuilder (import ./craft-apps/designcraft/default.nix);
  vectorcraft-bin = craftBuilder (import ./craft-apps/vectorcraft/default.nix);
  pdfcraft-bin = craftBuilder (import ./craft-apps/pdfcraft/default.nix);
  effectcraft-bin = craftBuilder (import ./craft-apps/effectcraft/default.nix);
  wordcraft-bin = craftBuilder (import ./craft-apps/wordcraft/default.nix);
  deckcraft-bin = craftBuilder (import ./craft-apps/deckcraft/default.nix);
  gridcraft-bin = craftBuilder (import ./craft-apps/gridcraft/default.nix);
  cadcraft-bin = craftBuilder (import ./craft-apps/cadcraft/default.nix);
  soundcraft-bin = craftBuilder (import ./craft-apps/soundcraft/default.nix);

  mempalace = pkgs.python3.pkgs.callPackage ./mempalace {};
  munder-difflin-bin = pkgs.callPackage ./munder-difflin-bin {};
  orca-bin = pkgs.callPackage ./orca-bin {};
  openfortigui = pkgs.callPackage ./openfortigui {};
  prince-bin = pkgs.callPackage ./prince-bin {};
  zed-preview-bin = pkgs.callPackage ./zed-preview-bin {};
}
