final: prev: let
  wrapCCWith = with prev;
    {
      cc,
      # This should be the only bintools runtime dep with this sort of logic. The
      # Others should instead delegate to the next stage's choice with
      # `targetPackages.stdenv.cc.bintools`. This one is different just to
      # provide the default choice, avoiding infinite recursion.
      bintools ?
        if targetPlatform.isDarwin
        then darwin.binutils
        else binutils,
      libc ? bintools.libc,
      ...
    } @ extraArgs:
      callPackage ../flang-overlay/build-support/cc-wrapper (let
        self =
          {
            nativeTools = targetPlatform == hostPlatform && stdenv.cc.nativeTools or false;
            nativeLibc = targetPlatform == hostPlatform && stdenv.cc.nativeLibc or false;
            nativePrefix = stdenv.cc.nativePrefix or "";
            noLibc = !self.nativeLibc && (self.libc == null);

            isGNU = cc.isGNU or false;
            isClang = cc.isClang or false;

            inherit cc bintools libc;
          }
          // extraArgs;
      in
        self);

  armPackages = {
    version,
    sha256,
    release_version,
    llvmPackages ? null,
    gccForLibs ? prev.gccForLibs,
  }: let
    mkExtraBuildCommands = cc: flang:
      ''
        ${prev.lib.optionalString (flang != null) "echo \"-I${flang}/include -L${flang}/lib -Wl,-rpath ${flang}/lib -B${flang}/bin\" >> $out/nix-support/cc-cflags"}
        rsrc="$out/resource-root"
        mkdir "$rsrc"

        if test ! -e ${cc}/lib/clang/${release_version}; then
          exit 1
        fi

        ln -s "${cc}/lib/clang/${release_version}/include" "$rsrc"
        ln -s "${cc}/lib" "$rsrc/lib"
        echo "-resource-dir=$rsrc" >> $out/nix-support/cc-cflags
      ''
      + prev.lib.optionalString prev.stdenv.targetPlatform.isLinux ''
        echo "--gcc-toolchain=${gccForLibs} -B${gccForLibs}" >> $out/nix-support/cc-cflags
      '';
  in rec {
    inherit
      (prev.callPackage ./arm-compiler-for-hpc {
        inherit version sha256;
      })
      unwrapped
      armpl
      ;
    arm = wrapCCWith rec {
      cc = unwrapped;
      extraPackages = [
      ];
      extraBuildCommands = mkExtraBuildCommands cc cc;
    };
    stdenv = let
      stdenv' = prev.overrideCC prev.stdenv arm;
    in
      stdenv'
      // {
        mkDerivation = args:
          stdenv'.mkDerivation (args
            // {
              ALLINEA_LICENCE_FILE = "/ccc/products/ccc_users_env/etc/allinea/Licence.arm";
              impureEnvVars =
                (args.impureEnvVars or [])
                ++ [
                  "ALLINEA_LICENCE_FILE"
                ];
            });
      };
  };
in {
  armPackages_190 = armPackages {
    version = "19.0";
    sha256 = "1c8843c6fd24ea7bfb8b4847da73201caaff79a1b8ad89692a88d29da0c5684e";
    release_version = "7.1.0";
    llvmPackages = prev.llvmPackages_7;
  };
  armPackages_191 = armPackages {
    version = "19.1";
    sha256 = "0hps82y7ga19n38n2fkbp4jm21fgbxx3ydqdnh0rfiwmxhvya07a";
    release_version = "7.1.0";
    llvmPackages = prev.llvmPackages_7;
  };
  armPackages_192 = armPackages {
    version = "19.2";
    sha256 = "1zdn7dq05c7fjnh1wfgxkd5znrxy0g3h0kpyn3gar6n2qdl0j22v";
    release_version = "7.1.0";
    llvmPackages = prev.llvmPackages_7;
  };
  armPackages_193 = armPackages {
    version = "19.3";
    sha256 = "c21ba30180e173fd505998526f73df1e18b48c74d1249162ee0a9a101125b0d8";
    release_version = "7.1.0";
    llvmPackages = prev.llvmPackages_7;
  };
  armPackages_200 = armPackages {
    version = "20.0";
    sha256 = "1kvl6fqc2yv4wwmdxgdwksnxlcz7h5b6jcsjbr466ggrn8b0hd4m";
    release_version = "9.0.1";
    llvmPackages = prev.llvmPackages_8;
  };

  armPackages_203 = armPackages {
    version = "20.3.2";
    sha256 = "1rivj6fa0m1qynzl2sjgqx79728y91v91ynjwr3x6w67fxb38mzi";
    release_version = "9.0.1";
    llvmPackages = prev.llvmPackages_9;
  };

  armie_192 = (final.callPackage ./arm-instruction-emulator {}).armie;
  armie_200 =
    (final.callPackage ./arm-instruction-emulator {
      version = "20.0";
      sha256 = "0mabjqf7ixnammxcmqgyssmmxdal8p74gbw390z8lsrvb8hpxb33";
    })
    .armie;
}
