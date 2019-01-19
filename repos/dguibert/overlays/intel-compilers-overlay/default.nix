self: super:
let
    # Intel compiler
    intelPackages = version:
      let
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
        isIntel = true;

        inherit cc bintools libc;
      } // extraArgs; in self);


      in rec {
      redist = self.callPackage ./redist.nix { inherit version; };
      unwrapped = self.callPackage ./compiler.nix { inherit version; };

      compilers = wrapCCWith {
        cc = unwrapped;
        extraPackages = [ redist super.which super.binutils ];
      };

      /* Return a modified stdenv that uses Intel compilers */
      stdenv = let stdenv_=super.overrideCC super.stdenv compilers; in stdenv_ // {
        mkDerivation = args: stdenv_.mkDerivation (args // {
          postFixup = "${args.postFixup or ""}" + ''
          set -x
          storeId=$(echo "${compilers}" | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")
          find $out -not -type d -print0 | xargs -0 sed -i -e  "s|$NIX_STORE/$storeId-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g"
          storeId=$(echo "${unwrapped}" | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")
          find $out -not -type d -print0 | xargs -0 sed -i -e  "s|$NIX_STORE/$storeId-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g"
          set +x
          '';
        });
      };

      mpi = super.callPackage ./mpi.nix { inherit version; };
    };

in {
    # https://software.intel.com/en-us/articles/intel-compiler-and-composer-update-version-numbers-to-compiler-version-number-mapping
    intelPackages_2016_0_109 = intelPackages "2016.0.109";
    intelPackages_2016_1_150 = intelPackages "2016.1.150";
    intelPackages_2016_2_181 = intelPackages "2016.2.181";
    intelPackages_2016_3_210 = intelPackages "2016.3.210";
    intelPackages_2016_3_223 = intelPackages "2016.3.223";
    intelPackages_2016_4_258 = intelPackages "2016.4.258";
    intelPackages_2016 = self.intelPackages_2016_4_258;

    intelPackages_2017_0_098 = intelPackages "2017.0.098";
    intelPackages_2017_1_132 = intelPackages "2017.1.132";
    intelPackages_2017_2_174 = intelPackages "2017.2.174";
    intelPackages_2017_4_196 = intelPackages "2017.4.196";
    intelPackages_2017_5_239 = intelPackages "2017.5.239";
    intelPackages_2017_7_259 = intelPackages "2017.7.259";
    intelPackages_2017 = self.intelPackages_2017_7_259;

    intelPackages_2018_0_128 = intelPackages "2018.0.128";
    intelPackages_2018_1_163 = intelPackages "2018.1.163";
    intelPackages_2018_2_199 = intelPackages "2018.2.199";
    intelPackages_2018_3_222 = intelPackages "2018.3.222";
    intelPackages_2018_5_274 = intelPackages "2018.5.274";
    intelPackages_2018 = self.intelPackages_2018_5_274;

    intelPackages_2019_0_117 = intelPackages "2019.0.117";
    intelPackages_2019_1_144 = intelPackages "2019.1.144";
    intelPackages_2019 = self.intelPackages_2019_1_144;

    stdenvIntel = self.intelPackages_2019.stdenv;

    helloIntel = super.hello.override { stdenv = self.stdenvIntel; };
    miniapp-ping-pongIntel = super.miniapp-ping-pong.override { stdenv = self.stdenvIntel;
      caliper = super.caliper.override { stdenv = self.stdenvIntel;
        mpi = self.intelPackages_2019.mpi;
      };
      mpi = self.intelPackages_2019.mpi;
    };

    hemocellIntel = super.hemocell.override {
      stdenv = self.stdenvIntel;
      hdf5 = (super.hdf5-mpi.override {
        stdenv = self.stdenvIntel;
        mpi = self.intelPackages_2019.mpi;
      }).overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [
          "CC=${self.intelPackages_2019.mpi}/bin/mpiicc"
        ];
      });
    };
}
