{lib, fetchFromGitHub, writeTextFile, fetchzip}:
let
    bootstrapseeds = fetchFromGitHub {
        owner = "oriansj";
        repo = "bootstrap-seeds";
        rev = "6d3fb087efe2d7cc7938cf2aff0265c6bfc86370";
        sha256 = "sha256-/fsl6Ds1U8rvBCdwH3YpEI5vVBSCsalW55oap2TAREc=";
    };
    mescctoolsseed = fetchFromGitHub {
        owner = "oriansj";
        repo = "stage0-posix";
        rev = "957c268024d7b750f7b43d5531aee156d018ae8c";
        sha256 = "sha256-vEB1lQdk03+kraDA2X0qIBO7hGUIWDUdio367H0ig9s=";
    };
    m2planet = fetchFromGitHub {
        owner = "oriansj";
        repo = "M2-Planet";
        rev = "09acd6253d3a1c81468f42ed3d23b9c4606e52c3";
        sha256 = "sha256-1CEi49+sFx/f7Ir0e4CuxdL255vAqt9UIfZL3XAC9kg=";
    };
    mescctools = fetchFromGitHub {
        owner = "oriansj";
        repo = "mescc-tools";
        rev = "5768b2a79036f34b9bd420ab4801ad7dca15dff8";
        sha256 = "sha256-z8gi5xZ2CMsbKq69uzRtlyzixtNrPFumfQN4XIy7chU=";
    };
    # mes = fetchzip {
    #     url = "https://git.savannah.gnu.org/cgit/mes.git/snapshot/mes-2ab4c5c676cb66088b0fb8de03b40b01f07bd4e0.tar.gz";
    #     sha256 = "sha256-a9Qc1bfu35uo0R+Se96vTUPNBlHjaht05wvsuWLwS0M=";
    # };

    # An extremely limited mkdir writeen in M1 to help create $out
    mkdirm1 = ./mkdir.M1;

    # The seed kaem is very limited
    seed-script = writeTextFile {
        name = "kaem.run";
        text = (import ./mescc-tools-seed-kaem.nix {inherit bootstrapseeds mescctoolsseed m2planet mescctools full-script mkdirm1; });
    };

    # The full kaem can follow up with this script
    full-script = ./mescc-tools-full-kaem.kaem;
in
derivation {
  name = "mescc-tools";
  version = "2021-01-09";

  # I got no idar why ci.nix needs this
  outputs = [ "out" ];

  inherit bootstrapseeds;
  inherit mescctoolsseed;
  inherit m2planet;
  inherit mescctools;

  builder = "${bootstrapseeds}/POSIX/x86/kaem-optional-seed";

  args = [ "${seed-script}" ];

  system = "x86_64-linux";

  description = "Bootstrapping tools for MES";
  homepage = "https://github.com/oriansj/stage0-posix";
  license = "gpl3Only";
}
