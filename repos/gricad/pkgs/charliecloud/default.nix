{ stdenv, fetchurl, bash, python }:

stdenv.mkDerivation rec {

    version = "0.9.9";
    name = "charliecloud-${version}";
    bats_version = "0.4.0";

   srcs = 
      [ (fetchurl {
           url = "https://github.com/hpc/charliecloud/archive/v${version}.tar.gz";
           sha256 = "0dj7sywy1knvz8492gm2hn8inh7cxb777y5cl2ycj0csn6hca916";
         })
        (fetchurl {
           url = "https://github.com/sstephenson/bats/archive/v${bats_version}.tar.gz";
           sha256 = "1myqq56kzwqc7p3inxiv2wgc06kfy3rjf980s5wfw7k8y5j8s3a8";
         })
      ];

    patches = [ ./CONDUCT.md_not_present_into_bats_release.patch ];

    buildInputs = [ bash python ];

    sourceRoot = "${name}";

    preBuild = ''
     # patchShebangs test/make-auto     
      cp VERSION VERSION.full
      export PREFIX=$out
      cp -a ../bats-${bats_version}/* test/bats/
     '';

 

}
