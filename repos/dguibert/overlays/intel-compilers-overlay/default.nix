self: super:
{
    # Intel compiler
    intel-compilers = { version, sha256
                      , preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux" # copy from /$preinstDir where it has been installed 
                      , withMPI_ ? false }:
      let
      preinstDirMPI = preinstDir + "/mpi";
      withMPI = builtins.pathExists preinstDirMPI || withMPI;
      wrapCCWith = { cc
        , # This should be the only bintools runtime dep with this sort of logic. The
          # Others should instead delegate to the next stage's choice with
          # `targetPackages.stdenv.cc.bintools`. This one is different just to
          # provide the default choice, avoiding infinite recursion.
          bintools ? if super.targetPlatform.isDarwin then super.darwin.binutils else super.binutils
        , libc ? bintools.libc
        , ...
        } @ extraArgs:
          super.callPackage ./build-support/cc-wrapper (let self = {
        nativeTools = super.targetPlatform == super.hostPlatform && super.stdenv.cc.nativeTools or false;
        nativeLibc = super.targetPlatform == super.hostPlatform && super.stdenv.cc.nativeLibc or false;
        nativePrefix = super.stdenv.cc.nativePrefix or "";
        noLibc = !self.nativeLibc && (self.libc == null);
  
        isGNU = cc.isGNU or false;
        isClang = cc.isClang or false;
        isIntelCompilers = true;
  
        inherit cc bintools libc;
      } // extraArgs; in self);


      in rec {
      unwrapped = self.callPackage ./compiler.nix { inherit version sha256 preinstDir; };

      wrapped = wrapCCWith {
        cc = unwrapped;
        extraPackages = [ super.which super.binutils ];
      };

      /* Return a modified stdenv that uses Intel compilers */
      stdenv = super.overrideCC super.stdenv wrapped;

      mpi = super.lib.mkIf withMPI (super.callPackage ./mpi.nix { inherit preinstDirMPI version; });
    };

    # https://software.intel.com/en-us/articles/intel-compiler-and-composer-update-version-numbers-to-compiler-version-number-mapping
    intel-compilers_2016_0_109 = self.intel-compilers { version="2016.0.109"; sha256="";};
    intel-compilers_2016_1_150 = self.intel-compilers { version="2016.1.150"; sha256="";};
    intel-compilers_2016_2_181 = self.intel-compilers { version="2016.2.181"; sha256="";};
    intel-compilers_2016_3_210 = self.intel-compilers { version="2016.3.210"; sha256="";};
    intel-compilers_2016_3_223 = self.intel-compilers { version="2016.3.223"; sha256="";};
    intel-compilers_2016_4_258 = self.intel-compilers { version="2016.4.258"; sha256="";};
    intel-compilers_2016 = self.intel-compilers_2016_4_258;

    intel-compilers_2017_0_098 = self.intel-compilers { version="2017.0.098"; sha256="";};
    intel-compilers_2017_1_132 = self.intel-compilers { version="2017.1.132"; sha256="";};
    intel-compilers_2017_2_174 = self.intel-compilers { version="2017.2.174"; sha256="";};
    intel-compilers_2017_4_196 = self.intel-compilers { version="2017.4.196"; sha256="";};
    intel-compilers_2017_5_239 = self.intel-compilers { version="2017.5.239"; sha256="";};
    intel-compilers_2017_7_259 = self.intel-compilers { version="2017.7.259"; sha256="";};
    intel-compilers_2017 = self.intel-compilers_2017_7_259;

    intel-compilers_2018_0_128 = self.intel-compilers { version="2018.0.128"; sha256="";};
    intel-compilers_2018_1_163 = self.intel-compilers { version="2018.1.163"; sha256="";};
    intel-compilers_2018_2_199 = self.intel-compilers { version="2018.2.199"; sha256="";};
    intel-compilers_2018_3_222 = self.intel-compilers { version="2018.3.222"; sha256="";};
    intel-compilers_2018_5_274 = self.intel-compilers { version="2018.5.274"; sha256="";};
    intel-compilers_2018 = self.intel-compilers_2018_3_222;

    intel-compilers_2019_0_117 = self.intel-compilers { version="2019.0.117"; sha256="1qhicj98x60csr4a2hjb3krvw74iz3i3dclcsdc4yp1y6m773fcl"; };
    intel-compilers_2019_1_144 = self.intel-compilers { version="2019.1.144"; sha256="1rhcfbig0qvkh622cvf8xjk758i3jh2vbr5ajdgms7jnwq99mii8"; };
    intel-compilers_2019 = self.intel-compilers_2019_1_144;

    stdenvIntel = self.intel-compilers_2019.stdenv;

    helloIntel = super.hello.override { stdenv = self.stdenvIntel; };

    hemocellIntel = super.hemocell.override {
      stdenv = self.stdenvIntel;
      hdf5 = (super.hdf5-mpi.override {
        stdenv = self.stdenvIntel;
        mpi = self.intel-compilers_2017.mpi;
      }).overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [
          "CC=${self.intel-compilers_2017.mpi}/bin/mpiicc"
        ];
      });
    };
}
