{ stdenv, lib, fetchzip, jdk, makeWrapper, installShellFiles, coreutils, gnused, bash }:
let
  pname = "micronaut";
in rec {
  micronautGen = import ./gen.nix;

  micronaut-1_3_4 = micronautGen rec {
    inherit stdenv lib jdk makeWrapper installShellFiles coreutils gnused bash pname;
    version = "1.3.4";
    src = fetchzip {
      url = "https://github.com/micronaut-projects/micronaut-core/releases/download/v${version}/${pname}-${version}.zip";
      sha256 = "0mddr6jw7bl8k4iqfq3sfpxq8fffm2spi9xwdr4cskkw4qdgrrpz";
    };
  };

  micronaut-1_3_5 = micronautGen rec {
    inherit stdenv lib jdk makeWrapper installShellFiles coreutils gnused bash pname;
    version = "1.3.5";
    src = fetchzip {
      url = "https://github.com/micronaut-projects/micronaut-core/releases/download/v${version}/${pname}-${version}.zip";
      sha256 = "16n1dk9jgy78mrkvr78m4x772kn09y5aa4d06wl4sdgn6apcq2mc";
    };
  };
}
