{
  lib,
  python3,
  stdenvNoCC,
  git,
  nix,
  kubernetes-helm,
}:
let
  python = python3.withPackages (ps: [
    ps.click
    ps.pyyaml
  ]);
in
stdenvNoCC.mkDerivation {
  name = "nixhelm-update";

  buildCommand = ''
    mkdir -p $out/bin
    (
      echo "#!${python.interpreter}"
      cat "${./nixhelm-update.py}"
    ) >$out/bin/nixhelm-update
    substituteInPlace $out/bin/nixhelm-update --replace-fail '@git@' '${git}/bin/git'
    substituteInPlace $out/bin/nixhelm-update --replace-fail '@helm@' '${kubernetes-helm}/bin/helm'
    substituteInPlace $out/bin/nixhelm-update --replace-fail '@nix-hash@' '${nix}/bin/nix-hash'
    substituteInPlace $out/bin/nixhelm-update --replace-fail '@nix@' '${nix}/bin/nix'
    chmod +x $out/bin/nixhelm-update
  '';

  meta = {
    mainProgram = "nixhelm-update";
    platforms = lib.platforms.all;
  };
}
