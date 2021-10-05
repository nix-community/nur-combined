let
  # Niv based pinning of packages.
  # Uses nixpkgs-unstable and NixOS-QChem master
  sources = import ./nix/sources.nix;
  qchemOvl = import sources.NixOS-QChem;
  nixpkgs = import sources.nixpkgs;
  pkgs = nixpkgs {
    overlays = [ qchemOvl haskellOverlay ];
    config = {
      allowUnfree = true;
      qchem-config = {
        allowEnv = true;
        optAVX = false;
      };
    };
  };

  # Haskell packages are automatically generated from Hackage and
  # often require a minor fix. In this case ConClusion gets
  # massiv-0.6.1.0 from nixpkgs, but requires massiv-1.0.0.0.
  # The dependency is therefore overridden, to make the package
  # compile.
  haskellOverlay = self: super: {
    haskellPackages = super.haskellPackages.extend (hself: hsuper: {
      My_Massiv = hsuper.callHackageDirect {
        pkg = "massiv";
        ver = "1.0.0.0";
        sha256 = "v4CDf7m/VsVNgrKHC42L56ip9jvbbLcSurH8mGRK0Qo=";
      } { scheduler = hself.scheduler_2_0_0; };

      ConClusion = hsuper.callHackageDirect {
        pkg = "ConClusion";
        ver = "0.1.0";
        sha256 = "rFzkxzSOF+LTddt06ClXzSu6hJLAZQONVD/erdUlcu8=";
      } { massiv = hself.My_Massiv; };
    });
  };

  # Python environment with interpreter and bundled packages.
  # Provides also jupyter-lab and the Jupyter kernel.
  pythonWithPackages = pkgs.qchem.python3.withPackages (p: with p; [
    jupyterlab
    numpy
    ipympl
    pandas
    psi4
    gpaw
    ase
  ]);

  # Haskell environment with interpreter, compiler, and bundled packages.
  # Provides the Haskell iHaskell kernel for Jupyter.
  haskellWithPackages = pkgs.haskellPackages.ghcWithPackages (p: with p; [
    ihaskell
    ConClusion
    attoparsec
    rio
    Chart
    Chart-cairo
  ]);

in with pkgs; mkShell {
  buildInputs = [
    pythonWithPackages
    haskellWithPackages
  ];

  shellHook = ''
    # Haskell preparation.
    # The iHaskell kernel needs GHC_PACKAGE_PATH to actually
    # find the packages, that were given.
    # 'ihaskell install' is required, so that jupyter finds
    # the haskell kernel.
    export GHC_PACKAGE_PATH="$(echo ${haskellWithPackages}/lib/*/package.conf.d| tr ' ' ':'):$GHC_PACKAGE_PATH"
    ihaskell install

    # Launch jupyter interface in the browser.
    jupyter-lab
  '';
}
