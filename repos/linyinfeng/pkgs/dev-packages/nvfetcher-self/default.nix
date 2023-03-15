{ haskellPackages, nvchecker, nix-prefetch, makeWrapper, lib }:

let
  drv = haskellPackages.callPackage ./nvfetcher-self.nix { };
in
drv.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
  postInstall = (old.postInstall or "") + ''
    wrapProgram $out/bin/nvfetcher-self \
      --prefix PATH : "${lib.makeBinPath [nvchecker nix-prefetch]}"
  '';
  meta = with lib; {
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ yinfeng ];
  };
})
