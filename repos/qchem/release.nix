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
      # Provide a handler to sort out unfree Packages
      # This creates a hard fail, which we can test with tryEval v.drvPath
      config.handleEvalIssue = reason: message:
        if reason == "unfree" then false
        else throw message;
      # config.checkMetaRecursively = true;
      config.inHydra = true;
    };

    makeForPython = plist:
      pkgSet.lib.foldr (a: b: a // b) {}
      (map (x: { "${x}" = hydraJobs pkgSet."${cfg.prefix}"."${x}".pkgs."${cfg.prefix}"; }) plist);

    # Filter out valid derivations
    hydraJobs = with pkgSet.lib; filterAttrs (n: v:
      isDerivation v && (if allowUnfree then true else (builtins.tryEval v.drvPath).success)
    );

    # Filter Attributes from set by name and put them in a list
    selectList = attributes: pkgs: with pkgSet.lib; mapAttrsToList (n: v: v)
      (filterAttrs (attr: val: (foldr (a: b: a == attr || b) false attributes)) pkgs);

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
          constituents = selectList [ "molden" ] ( hydraJobs pkgSet."${cfg.prefix}" )
            ++
            selectList [
              "cp2k"
              "nwchem"
              "molcas"
              "molpro"
              "mesa-qc"
              "qdng"
            ] ( hydraJobs pkgSet."${cfg.prefix}".tests );
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
