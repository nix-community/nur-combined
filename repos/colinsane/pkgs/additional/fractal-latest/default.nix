{ fractal-next, fetchFromGitLab, rustPlatform }:

(fractal-next.overrideAttrs (prev: rec {
  version = "20221220";
  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    rev = "d394badd0bf36c43026e01dbeb1cd7f881cf3440";
    hash = "sha256-JgLrDrMLEh7302tZ3NOJ12dCMiSxGgecaUjcuDPcGSg=";
  };
  patches = [];
  postPatch = "";
  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    hash = "sha256-hHsMcU6s42yKn2+LkWraLDhnmWNY72dL2cJoy6uoOKI=";
  };
}))
