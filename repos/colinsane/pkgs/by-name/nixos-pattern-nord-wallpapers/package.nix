{
  fetchFromGitea,
  imagemagick,
  lib,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "nixos-pattern-nord-wallpapers";
  version = "0-unstable-2026-06-13";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "abmurrow";
    repo = "nixos-pattern-nord-wallpapers";
    rev = "967f7431d5241d641a9519cd2041f321e050c83e";
    hash = "sha256-gppPbLooWOnJ1/W0rG/2WXLcwpSyjG8/S2hNoxPwpEA=";
  };

  nativeBuildInputs = [ imagemagick ];

  # or:
  #   inkscape svgs/$background -o ''${background/.svg/.png}
  # but imagemagick usually (cross) compiles more reliably than inkscape
  buildPhase = ''
    for background in $(ls svgs); do
      magick convert svgs/$background ''${background/.svg/.png}
    done
  '';

  installPhase = ''
    mkdir -p $out/share/backgrounds
    cp svgs/*.svg *.png $out/share/backgrounds
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://codeberg.org/abmurrow/nixos-pattern-nord-wallpapers";
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
}
