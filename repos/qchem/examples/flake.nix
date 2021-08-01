#
# Example of a custom flake.nix which configures the overlay.
# Place this file into a separate git repository.
#
{
  description = "Example of custom flake, using the NixOS-QChem Overlay";

  inputs = {
    qchem.url = "github:markuskowa/NixOS-QChem/master";
  };

  outputs = { self, qchem, nixpkgs } : let
    system = "x86_64-linux";
    pkgs = ((import qchem.inputs.nixpkgs) {
      inherit system;
      overlays = [
        qchem.overlay

        # custom overlay
        (self: super: {
          qchem = super.qchem // {
            qdng = null;
            mctdh = null;
            mesa-qc = null;
          };

          # Use mpich globally
          mpi = super.mpich;
        })
      ];

      # custom config
      config = {
        allowUnfree = true;
        config.qchem-config = {
          allowEnv = false;
          optAVX = true;
          # provide a download location for non-free packages
          srcurl = "http://files/sw";
        };
      };
    }).qchem;
  in {
    packages."${system}" = pkgs;
    checks."${system}" = pkgs.tests;
  };
}

