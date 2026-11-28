{
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-tag-media";
  srcRoot = ./.;
  packages = {
    "python3.pkgs.mutagen" = python3.pkgs.mutagen;
    "python3.pkgs.pyexiftool" = python3.pkgs.pyexiftool;
    "python3.pkgs.pykakasi" = python3.pkgs.pykakasi;
    "python3.pkgs.unidecode" = python3.pkgs.unidecode;
  };
}
