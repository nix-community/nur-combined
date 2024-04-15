{
  stdenv,
  fetchsvn,
  gfortran,
  openmpi,
  mpi ? openmpi,
  netcdf,
  netcdffortran,
  hdf5,
  perl,
  perlPackages,
  substituteAll,
  xios_10, # for nemo_36
  xios,
  fetchpatch,
  lib,
  callPackage,
}: let
  versions = {
    "4.0.2-12660-GO8_package" = {
      version = "4.0.2-12660-GO8_package";
      src = fetchsvn {
        url = "http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/branches/UKMO/NEMO_4.0.2_GO8_package";
        rev = "12660";
        sha256 = "sha256-AiYaw4Wuds5ZMCih1mb0yZY8ccFJ1Ok8N1icsaXjrjI=";
      };
    };
  };

  self = {
    nemo_gyre_pisces_4_0 = callPackage ./generic.nix ({config = "GYRE_PISCES";} // versions."4.0-10741");
    nemo_bench_4_0_2 = callPackage ./generic.nix ({config = "BENCH";} // versions."4.0.2-12578");
    nemo_gyre_pisces_4_0_2 = callPackage ./generic.nix ({config = "GYRE_PISCES";} // versions."4.0.2-12578");

    nemo_meto_go8_4_0_2 = (callPackage ./generic.nix ({config = "METO_GO";} // versions."4.0.2-12660-GO8_package")).overrideAttrs (o: {
      patches = [
        (fetchpatch {
          name = "nemo-4.0.1_GO8_package-fix-duplicate.patch";
          url = "https://forge.ipsl.jussieu.fr/nemo/changeset/12540/NEMO/branches/UKMO/NEMO_4.0.1_GO8_package_Intelfix?format=diff&new=12540";
          sha256 = "sha256-dDLIcUaEdNdiOcHQ3BztWeLTlgih0AI4UN7pzbcmsF8=";
          stripLen = 3;
        })
      ];
      postPatch =
        o.postPatch
        + ''
          echo "bld::tool::fppkeys   key_mpp_mpi key_si3 key_nosignedzero key_iomput" > cfgs/METO_GO/cpp_METO_GO.fcm
          echo "METO_GO OCE ICE" >> cfgs/ref_cfgs.txt
        '';
    });

    nemo = builtins.trace "nemo_bench_4_0" self.nemo_bench_4_0;
  };
in
  self
