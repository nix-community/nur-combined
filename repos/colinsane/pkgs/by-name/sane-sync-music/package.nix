{
  ffmpeg,
  python3,
  sox,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "sane-sync-music";
  srcRoot = ./.;
  packages = {
    inherit
      ffmpeg
      sox
      ;
    "python3.pkgs.unidecode" = python3.pkgs.unidecode;
  };
}
