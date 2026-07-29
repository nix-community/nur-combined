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
    substituteInPlace $out/bin/nixhelm-update \
      --replace-fail '@git@' '${git}/bin/git' \
      --replace-fail '@helm@' '${kubernetes-helm}/bin/helm' \
      --replace-fail '@nix-hash@' '${nix}/bin/nix-hash' \
      --replace-fail '@nix@' '${nix}/bin/nix'
    chmod +x $out/bin/nixhelm-update
  '';

  meta = {
    description = "Update pinned Helm chart versions and hashes in this repo";
    license = lib.licenses.mit;
    mainProgram = "nixhelm-update";
    platforms = lib.platforms.all;
  };
}
