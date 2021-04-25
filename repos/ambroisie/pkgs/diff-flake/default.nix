{ coreutils, git, gnused, lib, shellcheck, stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "diff-flake";
  version = "0.1.0";

  src = ./diff-flake;

  phases = [ "buildPhase" "installPhase" ];

  buildInputs = [
    shellcheck
  ];

  buildPhase = ''
    shellcheck $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/diff-flake
    substituteAllInPlace $out/bin/diff-flake
    patchShebangs $out/bin/diff-flake
  '';

  cat = "${coreutils}/bin/cat";
  mktemp = "${coreutils}/bin/mktemp";
  git = "${git}/bin/git";
  sed = "${gnused}/bin/sed";

  meta = with lib; {
    description = "Nix flake helper to visualize changes in closures";
    homepage = "https://gitea.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
  };
}
