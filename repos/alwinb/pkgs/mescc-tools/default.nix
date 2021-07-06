{lib, fetchFromGitHub, writeTextFile, fetchzip}:
let
    bootstrapseeds = fetchFromGitHub {
        owner = "oriansj";
        repo = "bootstrap-seeds";
        rev = "refs/tags/Release_1.0.0";
        sha256 = "sha256-/fsl6Ds1U8rvBCdwH3YpEI5vVBSCsalW55oap2TAREc=";
    };
    mescctoolsseed = fetchFromGitHub {
        owner = "oriansj";
        repo = "stage0-posix";
        rev = "refs/tags/Release_1.3";
        sha256 = "sha256-fJA6AHG6Z5h4GQgL98HuoXA7KDzxnkdXwLarjCj25DE=";
    };
    m2planet = fetchFromGitHub {
        owner = "oriansj";
        repo = "M2-Planet";
        rev = "refs/tags/Release_1.8.0";
        sha256 = "sha256-7HmhLqEs/KtSGEEfT0lhWOFThtAc0DZ5aMpHYMuSPc8=";
    };
    m2libc = fetchFromGitHub {
        owner = "oriansj";
        repo = "M2libc";
        rev = "refs/tags/Release_0.1";
        sha256 = "sha256-Hj/AXcso6Ki4oiO419vCkq7japajdNt1skYeR7fz9X8=";
    };
    mescctools = fetchFromGitHub {
        owner = "oriansj";
        repo = "mescc-tools";
        rev = "refs/tags/Release_1.2.0";  # official tree points one commit ahead
        sha256 = "sha256-Ipu5Yog5PkoX/9E8VcrIseQII+mJs3jWWtxw52LtxEQ=";
    };
    # mes = fetchzip {
    #     url = "https://git.savannah.gnu.org/cgit/mes.git/snapshot/mes-2ab4c5c676cb66088b0fb8de03b40b01f07bd4e0.tar.gz";
    #     sha256 = "sha256-a9Qc1bfu35uo0R+Se96vTUPNBlHjaht05wvsuWLwS0M=";
    # };

    # An extremely limited mkdir writeen in M1 to help create $out
    mkdirm1 = ./mkdir.M1;

    # The seed kaem is very limited
    seedscript = writeTextFile {
        name = "kaem.run";
        text = (import ./mescc-tools-seed-kaem.nix {inherit bootstrapseeds mescctoolsseed m2planet m2libc mescctools full-script mkdirm1; });
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
  inherit m2libc;
  inherit mescctools;
  inherit seedscript;

  builder = "${bootstrapseeds}/POSIX/x86/kaem-optional-seed";

  args = [ "${seedscript}" ];

  system = "x86_64-linux";

  description = "Bootstrapping tools for MES";
  homepage = "https://github.com/oriansj/stage0-posix";
  license = "gpl3Only";
}
