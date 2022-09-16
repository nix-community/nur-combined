{ haskellPackages, nvchecker, nix-prefetch-git, makeWrapper, lib }:

let
  drv = haskellPackages.callPackage ./updater.nix { };
in
drv.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
  postInstall = (old.postInstall or "") + ''
    wrapProgram $out/bin/updater \
      --prefix PATH : "${lib.makeBinPath [nvchecker nix-prefetch-git]}"
  '';
  meta = with lib; {
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "22.05");
    platforms = [ "x86_64-linux" ];
  };
})
