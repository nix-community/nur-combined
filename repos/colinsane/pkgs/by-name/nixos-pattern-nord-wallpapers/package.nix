{
  fetchFromGitea,
  inkscape,
  lib,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "nixos-pattern-nord-wallpapers";
  version = "0-unstable-2023-11-30";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "abmurrow";
    repo = "nixos-pattern-nord-wallpapers";
    rev = "006024c8844a6f7c86bfd91bb26774a1860e970e";
    hash = "sha256-Nng5qMzOv3ov4CdieRG30Xt5g+6T/zk2AOqtJNZThgI=";
  };

  nativeBuildInputs = [ inkscape ];

  buildPhase = ''
    for background in $(ls svgs); do
      inkscape svgs/$background -o ''${background/.svg/.png}
    done
  '';

  installPhase = ''
    mkdir -p $out/share/backgrounds
    cp svgs/*.svg *.png $out/share/backgrounds
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://codeberg.org/abmurrow/nixos-pattern-nord-wallpapers";
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
