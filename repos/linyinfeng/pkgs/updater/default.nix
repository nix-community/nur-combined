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
  meta.platforms = haskellPackages.ghc.meta.platforms;
})
