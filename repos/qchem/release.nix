{
  # nixpkgs sources
    nixpkgs ? { outPath = <nixpkgs>; shortRev = "0000000"; }

  # Override config from ENV
  , config ? {}
  # allowUnfree for nixpkgs
  , allowUnfree ? true
  # Additional overlays to apply (applied before and after the main Overlay)
  , preOverlays ? []
  , postOverlays ? []
  # Revision for Hydra
  , NixOS-QChem ? { shortRev = "0000000"; }
  # build more variants
  , buildVariants ? false
} :


let

  cfg = (import ./cfg.nix) config;

  # Customized package set
  pkgs = config: overlay: let
    pkgSet = (import nixpkgs) {
      overlays = [ overlay ] ++ preOverlays ++ [ (import ./default.nix) ] ++ postOverlays;
      config.allowUnfree = allowUnfree;
      config.qchem-config = cfg;
    };

    makeForPython = plist:
      pkgSet.lib.foldr (a: b: a // b) {}
      (map (x: { "${x}" = pkgSet."${cfg.prefix}"."${x}".pkgs."${cfg.prefix}"; }) plist);

    # Filter out derivations
    hydraJobs = with pkgSet.lib; filterAttrs (n: v: isDerivation v);

    # Make sure we only build the overlay's content
    pkgsClean = hydraJobs pkgSet."${cfg.prefix}"
      # Pick the test set
      // { tests = hydraJobs pkgSet."${cfg.prefix}".tests; }

      # release set for python packages
      // makeForPython [ "python2" "python3" ]

      # Have a manadatory test set and a channel
      // rec {
        tested = pkgSet.releaseTools.aggregate {
          name = "tested-programs";
          constituents = with pkgSet."${cfg.prefix}"; [
            tests.cp2k
            tests.nwchem
            tests.molcas
          ] ++ pkgSet.lib.optionals allowUnfree [
            molden
          ] ++ pkgSet.lib.optionals (cfg.srcurl != null && allowUnfree) [
            tests.molpro
            tests.mesa-qc
            tests.qdng
          ];
        };

        nixexprs = pkgSet.runCommand "nixexprs" {}
          ''
            mkdir -p $out/NixOS-QChem

            cp -r ${nixpkgs}/* $out/
            mv $out/default.nix $out/nixpkgs-default.nix

            cp -r ${./.}/* $out/NixOS-QChem
            cp ${./channel.nix} $out/default.nix

            # nixpkgs version
            cp ${nixpkgs}/.version $out/.version

            cat <<EOF > $out/.qchem-revision
            nixpkgs ${nixpkgs.shortRev}
            NixOS-QChem ${NixOS-QChem.shortRev}
            EOF
          '';

        channel = pkgSet.releaseTools.channel {
          name = "NixOS-QChem-channel";
          src = nixexprs;
          constituents = [ tested ];
        };
      };

  in pkgsClean;

in {
  qchem = pkgs (config // { optAVX = true; }) (self: super: {});
  qchem-noavx = pkgs (config // { optAVX = false; }) (self: super: {});

} # Extra variants for testing purposes
// (if buildVariants then {
  qchem-mpich = pkgs (config // { optAVX = true; }) (self: super: { mpi = super.mpich; });

  qchem-mkl = pkgs (config // { optAVX = true; }) (self: super: {
    blas = super.blas.override { blasProvider = super.mkl; };
    lapack = super.lapack.override { lapackProvider = super.mkl; };
  });

  qchem-amd = pkgs (config // { optAVX = true; }) (self: super: {
    blas = super.blas.override { blasProvider = super.amd-blis; };
    lapack = super.lapack.override { lapackProvider = super.amd-libflame; };
  });
}
else {})
